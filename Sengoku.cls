\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{Sengoku}[2026/09/05 v1.3.3 Reusable research-article class]

% Sengoku is derived from the project's original arXiv/technical-report
% template.  See NOTICE.md for provenance and third-party asset notices.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions\relax
\LoadClass{extarticle}

% Static fonts keep the Unicode engines on the same supported font path.
\RequirePackage{iftex}
\newif\ifSengoku@staticnoto
\ifPDFTeX
  \pdfminorversion=7
  \RequirePackage[T1]{fontenc}
  \RequirePackage[utf8]{inputenc}
  \IfFileExists{noto-serif.sty}{%
    \renewcommand{\rmdefault}{NotoSerif-TLF}
    \RequirePackage[medium]{noto-serif}
  }{\RequirePackage{tgbonum}}
\else
  \RequirePackage[no-math]{fontspec}
  \newcommand*{\Sengoku@tryStaticNoto}[1]{%
    \IfFontExistsTF{NotoSerif-Medium.#1}{%
      \IfFontExistsTF{NotoSerif-Bold.#1}{%
        \IfFontExistsTF{NotoSerif-MediumItalic.#1}{%
          \IfFontExistsTF{NotoSerif-BoldItalic.#1}{%
            \setmainfont{NotoSerif}[
              Extension=.#1,UprightFont=*-Medium,BoldFont=*-Bold,
              ItalicFont=*-MediumItalic,BoldItalicFont=*-BoldItalic]
            \Sengoku@staticnototrue
          }{}%
        }{}%
      }{}%
    }{}%
  }
  \Sengoku@tryStaticNoto{otf}
  \ifSengoku@staticnoto\else\Sengoku@tryStaticNoto{ttf}\fi
  \ifSengoku@staticnoto\else
    \setmainfont{texgyrebonum}[
      Extension=.otf,UprightFont=*-regular,BoldFont=*-bold,
      ItalicFont=*-italic,BoldItalicFont=*-bolditalic]
    \ClassInfo{Sengoku}{Static Noto Serif unavailable; using TeX Gyre Bonum}
  \fi
\fi
\ifLuaTeX\pdfvariable minorversion=7\fi
\ifXeTeX\AtBeginDocument{\special{pdf:minorversion 7}}\fi
\DeclareRobustCommand{\SengokuSerif}{\rmfamily}
\renewcommand{\sfdefault}{\rmdefault}
\RequirePackage{fix-cm}
\RequirePackage[english]{babel}
\RequirePackage{microtype}
\RequirePackage[table,svgnames]{xcolor}
\RequirePackage{geometry}
\RequirePackage{graphicx}
\RequirePackage{adjustbox}
\RequirePackage{tabularx}
\RequirePackage{needspace}
\RequirePackage{fancyhdr}
\RequirePackage[explicit]{titlesec}
\RequirePackage{enumitem}
\RequirePackage[most]{tcolorbox}
\RequirePackage{caption}
\RequirePackage{etoolbox}
\RequirePackage{amsmath,amssymb,amsthm}
\RequirePackage[comma,authoryear,compress]{natbib}
\RequirePackage{hyperref}
\ifXeTeX
  \microtypesetup{protrusion=false,expansion=false,tracking=false}
\else
  \microtypesetup{protrusion=false,expansion=true,tracking=false}
\fi

% Restrained editorial palette.  Body copy remains exact #111111.
\definecolor{SengokuNavy}{HTML}{20384F}
\definecolor{SengokuAccent}{HTML}{9A6848}
\definecolor{SengokuSlate}{HTML}{68645F}
\definecolor{SengokuInk}{HTML}{111111}
\definecolor{SengokuLine}{HTML}{D4CDC2}
\definecolor{SengokuPaper}{HTML}{F8F5EF}
\definecolor{SengokuRose}{HTML}{934856}
% Searchable color stops reserved for the optional four-part paper title.
\definecolor{SengokuTitleRose}{HTML}{B64073}
\colorlet{SengokuTitleTransitionA}{SengokuNavy!68!SengokuTitleRose}
\colorlet{SengokuTitleTransitionB}{SengokuNavy!34!SengokuTitleRose}

% Four searchable text stops create a stable navy-to-rose title transition.
\NewDocumentCommand{\gradienttitle}{m m m m}{%
  \textcolor{SengokuNavy}{#1}\space
  \textcolor{SengokuTitleTransitionA}{#2}\space
  \textcolor{SengokuTitleTransitionB}{#3}\space
  \textcolor{SengokuTitleRose}{#4}%
}

\hypersetup{
  colorlinks=true,
  linkcolor=SengokuRose,
  citecolor=SengokuRose,
  urlcolor=SengokuRose,
  pdfborder={0 0 0}
}
\urlstyle{same}

\geometry{
  left=22mm,
  right=22mm,
  top=20mm,
  bottom=22mm,
  headheight=40pt,
  headsep=13pt,
  footskip=19pt
}

\setlength{\parskip}{0.44\baselineskip}
\setlength{\parindent}{0pt}
\setlength{\columnsep}{18pt}
\setlength{\emergencystretch}{3.75em}

% Manuscript-controlled branding, authorship, affiliation, and metadata.
% The class owns rendering only; every asset path and data row is declared in
% main.tex through the public commands below.
\ExplSyntaxOn

\seq_new:N  \g_sengoku_top_logo_seq
\tl_new:N   \g_sengoku_top_right_logo_tl
\tl_new:N   \g_sengoku_title_logo_tl
\seq_new:N  \g_sengoku_affiliation_id_seq
\prop_new:N \g_sengoku_affiliation_text_prop
\prop_new:N \g_sengoku_affiliation_logo_prop
\prop_new:N \g_sengoku_affiliation_logo_options_prop
\prop_new:N \g_sengoku_affiliation_number_prop
\int_new:N  \g_sengoku_affiliation_count_int
\seq_new:N  \g_sengoku_author_seq
\seq_new:N  \g_sengoku_metadata_seq
\tl_new:N   \g_sengoku_pdf_author_tl
\bool_new:N \l_sengoku_author_valid_bool
\tl_new:N   \g_sengoku_affiliation_layout_tl
\dim_new:N  \g_sengoku_top_logo_gap_dim
\dim_new:N  \g_sengoku_title_logo_xshift_dim
\dim_new:N  \g_sengoku_affiliation_gap_dim
\dim_new:N  \g_sengoku_metadata_row_gap_dim
\dim_new:N  \l_sengoku_title_logo_height_dim
\dim_new:N  \l_sengoku_title_logo_xshift_dim
\tl_gset:Nn \g_sengoku_affiliation_layout_tl { inline }
\dim_gset:Nn \g_sengoku_top_logo_gap_dim { 3.5mm }
\dim_gset:Nn \g_sengoku_title_logo_xshift_dim { 0pt }
\dim_gset:Nn \g_sengoku_affiliation_gap_dim { 1.0em }
\dim_gset:Nn \g_sengoku_metadata_row_gap_dim { 1.8mm }

\keys_define:nn { sengoku/title-logo }
  {
    height .dim_set:N = \l_sengoku_title_logo_height_dim,
    xshift .dim_set:N = \l_sengoku_title_logo_xshift_dim
  }

\cs_new_protected:Npn \sengoku_include_graphic:nn #1#2
  {
    \tl_if_blank:nTF {#1}
      { \includegraphics[keepaspectratio]{#2} }
      { \includegraphics[keepaspectratio,#1]{#2} }
  }

\cs_new_protected:Npn \sengoku_top_logo_item:nn #1#2
  {
    \adjustbox{valign=m}
      { \sengoku_include_graphic:nn {#1} {#2} }
  }

\NewDocumentCommand \toplogogap { m }
  { \dim_gset:Nn \g_sengoku_top_logo_gap_dim {#1} }

\NewDocumentCommand \addtoplogo { O{height=10.5mm} m }
  {
    \file_if_exist:nTF {#2}
      {
        \seq_gput_right:Nn \g_sengoku_top_logo_seq
          { \sengoku_top_logo_item:nn {#1} {#2} }
      }
      {
        \ClassWarning{Sengoku}
          {Top~logo~file~'#2'~not~found;~entry~ignored}
      }
  }

% An optional mark anchored to the right edge of the top branding row.
\NewDocumentCommand \righttoplogo { O{height=10.5mm} m }
  {
    \file_if_exist:nTF {#2}
      {
        \tl_gset:Nn \g_sengoku_top_right_logo_tl
          { \sengoku_top_logo_item:nn {#1} {#2} }
      }
      {
        \tl_gclear:N \g_sengoku_top_right_logo_tl
        \ClassWarning{Sengoku}
          {Right~top~logo~file~'#2'~not~found;~entry~ignored}
      }
  }

% A single, commentable command owns both the title-logo size and position.
% Example: \titlelogo[height=15mm,xshift=5mm]{logo.png}
\NewDocumentCommand \titlelogo { O{} m }
  {
    \group_begin:
      \dim_set:Nn \l_sengoku_title_logo_height_dim { 12mm }
      \dim_set:Nn \l_sengoku_title_logo_xshift_dim { 0pt }
      \keys_set:nn { sengoku/title-logo } {#1}
      \dim_gset:Nn \g_sengoku_title_logo_xshift_dim
        { \dim_use:N \l_sengoku_title_logo_xshift_dim }
      \file_if_exist:nTF {#2}
        {
          \tl_gset:Nx \g_sengoku_title_logo_tl
            {
              \exp_not:N \sengoku_include_graphic:nn
                { height=\dim_use:N \l_sengoku_title_logo_height_dim }
                { \exp_not:n {#2} }
            }
        }
        {
          \tl_gclear:N \g_sengoku_title_logo_tl
          \ClassWarning{Sengoku}
            {Title~logo~file~'#2'~not~found;~title~logo~disabled}
        }
    \group_end:
  }

% Registration stores only the ID and display text.  Logos are deliberately
% configured by a separate, commentable command so they are never mandatory.
\NewDocumentCommand \affiliation { m m }
  {
    \prop_if_in:NnTF \g_sengoku_affiliation_text_prop {#1}
      {
        \ClassError{Sengoku}
          {Duplicate~affiliation~ID~'#1'}
          {Use~a~unique~literal~ID~for~each~affiliation.}
      }
      {
        \int_gincr:N \g_sengoku_affiliation_count_int
        \seq_gput_right:Nn \g_sengoku_affiliation_id_seq {#1}
        \prop_gput:Nnn \g_sengoku_affiliation_text_prop {#1} {#2}
        \prop_gput:Nnn \g_sengoku_affiliation_logo_options_prop {#1} {}
        \prop_gput:Nnn \g_sengoku_affiliation_logo_prop {#1} {}
        \prop_gput:Nnx \g_sengoku_affiliation_number_prop {#1}
          { \int_use:N \g_sengoku_affiliation_count_int }
      }
  }

% Comment out any one of these calls in main.tex to hide only that badge.
\NewDocumentCommand \affiliationlogo { O{} m m }
  {
    \prop_if_in:NnTF \g_sengoku_affiliation_text_prop {#2}
      {
        \prop_gput:Nnn \g_sengoku_affiliation_logo_options_prop {#2} {#1}
        \prop_gput:Nnn \g_sengoku_affiliation_logo_prop {#2} {#3}
        \file_if_exist:nF {#3}
          {
            \ClassWarning{Sengoku}
              {Affiliation~logo~'#3'~for~ID~'#2'~not~found;~badge~omitted}
          }
      }
      {
        \ClassError{Sengoku}
          {Unknown~affiliation~ID~'#2'~for~logo}
          {Declare~the~affiliation~before~setting~its~optional~logo.}
      }
  }

% inline = centered automatic wrapping; rows = one institution per line;
% hidden = keep superscripts but omit the institution list.
\NewDocumentCommand \affiliationlayout { m }
  {
    \str_case:nnF {#1}
      {
        {inline}{\tl_gset:Nn \g_sengoku_affiliation_layout_tl {inline}}
        {rows}{\tl_gset:Nn \g_sengoku_affiliation_layout_tl {rows}}
        {hidden}{\tl_gset:Nn \g_sengoku_affiliation_layout_tl {hidden}}
      }
      {
        \ClassError{Sengoku}
          {Unknown~affiliation~layout~'#1'}
          {Use~inline,~rows,~or~hidden.}
      }
  }

\NewDocumentCommand \affiliationgap { m }
  { \dim_gset:Nn \g_sengoku_affiliation_gap_dim {#1} }

% Affiliations must be registered before their authors.  The public interface
% follows the familiar authblk form: \author[affiliation IDs]{Author Name}.
\cs_new_protected:Npn \sengoku_add_author:nn #1#2
  {
    \bool_set_true:N \l_sengoku_author_valid_bool
    \clist_map_inline:nn {#2}
      {
        \prop_if_in:NnF \g_sengoku_affiliation_text_prop {##1}
          {
            \bool_set_false:N \l_sengoku_author_valid_bool
            \ClassError{Sengoku}
              {Author~'#1'~uses~unknown~affiliation~ID~'##1'}
              {Declare~that~affiliation~before~this~author.}
          }
      }
    \bool_if:NT \l_sengoku_author_valid_bool
      {
        \seq_gput_right:Nn \g_sengoku_author_seq
          { \sengoku_author_item:nn {#1} {#2} }
        \tl_if_empty:NF \g_sengoku_pdf_author_tl
          { \tl_gput_right:Nn \g_sengoku_pdf_author_tl { ;~ } }
        \tl_gput_right:Nn \g_sengoku_pdf_author_tl {#1}
      }
  }

\RenewDocumentCommand \author { O{} m }
  { \sengoku_add_author:nn {#2} {#1} }

\cs_new_protected:Npn \sengoku_author_badge_file:nn #1#2
  {
    \tl_if_blank:nF {#2}
      {
        \file_if_exist:nT {#2}
          {
            \makebox[1.95em][c]
              {
                \raisebox
                  {\dimexpr.5\ht\strutbox-.5\dp\strutbox-.5\height-1.54pt\relax}
                  [0pt][0pt]
                  {
                    \tl_if_blank:nTF {#1}
                      { \includegraphics[pagebox=artbox,height=1.72em]{#2} }
                      { \includegraphics[pagebox=artbox,height=1.72em,#1]{#2} }
                  }
              }
            \kern .18em
          }
      }
  }

\cs_new_protected:Npn \sengoku_author_badges:n #1
  {
    \clist_map_inline:nn {#1}
      {
        \tl_set:Nx \l_tmpa_tl
          { \prop_item:Nn \g_sengoku_affiliation_logo_prop {##1} }
        \tl_set:Nx \l_tmpb_tl
          { \prop_item:Nn \g_sengoku_affiliation_logo_options_prop {##1} }
        \exp_args:NVV \sengoku_author_badge_file:nn \l_tmpb_tl \l_tmpa_tl
      }
  }

\cs_new_protected:Npn \sengoku_affiliation_numbers:n #1
  {
    \int_zero:N \l_tmpa_int
    \clist_map_inline:nn {#1}
      {
        \int_incr:N \l_tmpa_int
        \int_compare:nNnT {\l_tmpa_int} > {1} {,}
        \prop_item:Nn \g_sengoku_affiliation_number_prop {##1}
      }
  }

% Keep ordinary names together; unpack unusually wide names for line wrapping.
% Typeset only once so that title-note counters and text are not duplicated.
\box_new:N \l_sengoku_author_box
\cs_new_protected:Npn \sengoku_author_item:nn #1#2
  {
    \hbox_set:Nn \l_sengoku_author_box
      {
        \strut
        \sengoku_author_badges:n {#2}
        {\bfseries #1}
        \tl_if_blank:nF {#2}
          {\nobreak\textsuperscript{\sengoku_affiliation_numbers:n {#2}}}
      }
    \mode_leave_vertical:
    \dim_compare:nNnTF {\box_wd:N \l_sengoku_author_box} > {\linewidth}
      {\hbox_unpack_drop:N \l_sengoku_author_box}
      {\box_use_drop:N \l_sengoku_author_box}
  }

\cs_new_protected:Npn \sengoku_render_author_block:
  {
    \seq_if_empty:NF \g_sengoku_author_seq
      {
        \begingroup
          \centering
          {\normalfont\SengokuSerif
           \fontsize{10.6}{21.5}\selectfont\color{SengokuInk}
           \seq_use:Nn \g_sengoku_author_seq
             {,\allowbreak\hspace{.66em~plus~.20em~minus~.10em}}
           \par}
          \tl_if_eq:NnF \g_sengoku_affiliation_layout_tl {hidden}
            {
              \vspace{1.5mm}
              \begingroup
                \centering
                \normalfont\SengokuSerif
                \fontsize{8.8}{10.9}\selectfont\color{SengokuInk}
                \setlength{\parindent}{0pt}
                \setlength{\parskip}{.30mm}
                \tl_if_eq:NnTF \g_sengoku_affiliation_layout_tl {rows}
                  {
                    \seq_map_inline:Nn \g_sengoku_affiliation_id_seq
                      {
                        \textsuperscript
                          {\prop_item:Nn \g_sengoku_affiliation_number_prop {##1}}\,
                        \prop_item:Nn \g_sengoku_affiliation_text_prop {##1}\par
                      }
                  }
                  {
                    \int_zero:N \l_tmpa_int
                    \seq_map_inline:Nn \g_sengoku_affiliation_id_seq
                      {
                        \int_incr:N \l_tmpa_int
                        \int_compare:nNnT {\l_tmpa_int} > {1}
                          {\hspace{\g_sengoku_affiliation_gap_dim}\allowbreak}
                        \textsuperscript
                          {\prop_item:Nn \g_sengoku_affiliation_number_prop {##1}}\,\nobreak
                        \prop_item:Nn \g_sengoku_affiliation_text_prop {##1}
                      }
                    \par
                  }
              \par\endgroup
            }
        \endgroup
      }
  }

\NewDocumentCommand \metadatarowgap { m }
  { \dim_gset:Nn \g_sengoku_metadata_row_gap_dim {#1} }

% The icon is optional: \addmetadata[icon.pdf]{Label}{Value}.
\NewDocumentCommand \addmetadata { O{} m m }
  {
    \tl_if_blank:nF {#1}
      {
        \file_if_exist:nF {#1}
          {
            \ClassWarning{Sengoku}
              {Metadata~icon~'#1'~not~found;~empty~icon~box~used}
          }
      }
    \seq_gput_right:Nn \g_sengoku_metadata_seq
      { \sengoku_metadata_item:nnn {#1} {#2} {#3} }
  }

\cs_new_protected:Npn \sengoku_metadata_icon:n #1
  {
    \makebox[1.30em][c]
      {
        \file_if_exist:nT {#1}
          {
            \raisebox
              {\dimexpr.5\ht\strutbox-.5\dp\strutbox-.5\height\relax}
              {
                \adjustbox{max~width=1.05em,max~height=1.05em}
                  { \includegraphics{#1} }
              }
          }
      }
  }

\cs_new_protected:Npn \sengoku_metadata_item:nnn #1#2#3
  {
    \noindent\hangindent=\dimexpr1.30em+1.55mm\relax\hangafter=1
    \sengoku_metadata_icon:n {#1}\hspace{1.55mm}
    \strut\textbf{#2}:~#3\strut\par
  }

\cs_new_protected:Npn \sengoku_render_metadata:
  {
    \seq_if_empty:NF \g_sengoku_metadata_seq
      {
        \vspace{2.2mm}
        {\color{SengokuLine}\rule{\linewidth}{0.45pt}\par}
        \vspace{2.0mm}
        \begingroup
          \SengokuSerif\fontsize{9.4}{11.8}\selectfont
          \color{SengokuInk}\setlength{\parskip}{0pt}
          \seq_use:Nn \g_sengoku_metadata_seq
            {\vspace{\g_sengoku_metadata_row_gap_dim}}
        \endgroup
      }
  }

\cs_new_protected:Npn \sengoku_render_top_logo_block:
  {
    \bool_lazy_and:nnF
      { \seq_if_empty_p:N \g_sengoku_top_logo_seq }
      { \tl_if_empty_p:N \g_sengoku_top_right_logo_tl }
      {
        \noindent\hspace*{.03\textwidth}
        \begin{minipage}{.94\textwidth}
          \raggedright
          \seq_use:Nn \g_sengoku_top_logo_seq
            {\hspace{\g_sengoku_top_logo_gap_dim}\allowbreak}
          \tl_if_empty:NF \g_sengoku_top_right_logo_tl
            {\nobreak\hfill\tl_use:N \g_sengoku_top_right_logo_tl}
        \end{minipage}\par
        \vspace{1.0mm}
      }
  }

\NewDocumentCommand \SengokuIfTitleLogoTF {m m}
  {\tl_if_empty:NTF \g_sengoku_title_logo_tl {#2}{#1}}

\NewDocumentCommand \SengokuRenderTopLogoBlock { }
  { \sengoku_render_top_logo_block: }
\NewDocumentCommand \SengokuRenderTitleLogo { }
  {
    \hspace*{\g_sengoku_title_logo_xshift_dim}
    \tl_use:N \g_sengoku_title_logo_tl
  }
\NewDocumentCommand \SengokuRenderAuthorBlock { }
  { \sengoku_render_author_block: }
\NewDocumentCommand \SengokuRenderMetadata { }
  { \sengoku_render_metadata: }
\NewExpandableDocumentCommand \SengokuPDFAuthors { }
  { \tl_use:N \g_sengoku_pdf_author_tl }

\ExplSyntaxOff

\makeatletter
\newcommand*\Sengoku@abstract{}
\newcommand*\Sengoku@keywords{}
\newif\ifSengoku@titlemade
\RenewDocumentEnvironment{abstract}{+b}{%
  \ifSengoku@titlemade
    \ClassError{Sengoku}{Abstract must precede \string\maketitle}
      {Move the abstract environment before \string\maketitle.}%
  \else
    \gdef\Sengoku@abstract{#1}%
  \fi
}{}
\newcommand{\keywords}[1]{\gdef\Sengoku@keywords{#1}}
\newcommand{\articledate}{\@date}
\newcommand*{\Sengoku@shorttitle}{}
\newcommand*{\Sengoku@runningauthor}{}
\newcommand{\shorttitle}[1]{\gdef\Sengoku@shorttitle{#1}}
\newcommand{\runningauthor}[1]{\gdef\Sengoku@runningauthor{#1}}
\newcommand{\Sengoku@plaintitle}[4]{#1 #2 #3 #4}
\pdfstringdefDisableCommands{%
  \def\gradienttitle#1#2#3#4{#1 #2 #3 #4}%
  \def\thanks#1{}%
}

% Standard \thanks entries are title notes, kept next to the author block
% even when a long abstract makes the title card span several pages.
\newcounter{sengokutitlenote}
\newcommand*{\Sengoku@titlenotes}{}
\newcommand{\Sengoku@titlenote}[2]{\textsuperscript{\ensuremath{\dagger}#1}\,#2\par}
\newcommand{\Sengoku@thanks}[1]{%
  \stepcounter{sengokutitlenote}%
  \textsuperscript{\ensuremath{\dagger}\arabic{sengokutitlenote}}\kern.12em%
  \protected@xdef\Sengoku@titlenotes{%
    \Sengoku@titlenotes
    \protect\Sengoku@titlenote{\arabic{sengokutitlenote}}{#1}}%
}
\newcommand{\Sengoku@printtitlenotes}{%
  \ifx\Sengoku@titlenotes\@empty\else
    \vspace{1.5mm}%
    {\normalfont\SengokuSerif\fontsize{9.2}{11.8}\selectfont
     \color{SengokuInk}\Sengoku@titlenotes}%
  \fi
}

\renewcommand{\@makefnmark}{%
  \hbox{\@textsuperscript{\normalfont\SengokuSerif\color{SengokuInk}\@thefnmark}}%
}

% Lower the header text toward the rule without changing header/body geometry.
\newcommand{\Sengoku@headertext}[1]{\raisebox{-8pt}[\height][\depth]{#1}}
\fancypagestyle{sengoku}{%
  \fancyhf{}%
  \fancyhead[L]{\let\thanks\@gobble
    \normalfont\SengokuSerif\bfseries\fontsize{9.0}{10.6}\selectfont
    \color{SengokuNavy}\Sengoku@headertext{\adjustbox{max totalheight=25pt}{%
      \parbox[b]{.30\headwidth}{\raggedright\strut\nouppercase{\leftmark}}}}}%
  \fancyhead[R]{\let\thanks\@gobble
    \normalfont\SengokuSerif\bfseries\fontsize{8.7}{10.4}\selectfont
    \color{SengokuRose}\let\gradienttitle\Sengoku@plaintitle
    \Sengoku@headertext{\adjustbox{max totalheight=25pt}{%
      \parbox[b]{.66\headwidth}{\raggedleft\strut\nouppercase{\rightmark}}}}}%
  \fancyfoot[C]{\normalfont\SengokuSerif\fontsize{8.2}{10}\selectfont\color{SengokuSlate}\thepage}%
  \renewcommand{\headrulewidth}{0.70pt}%
  \renewcommand{\footrulewidth}{0pt}%
  \renewcommand{\headrule}{%
    \hbox to\headwidth{%
      {\color{SengokuNavy}\leaders\hrule height 0.55pt\hfill}%
      {\color{SengokuAccent}\rule{3mm}{0.70pt}}%
      {\color{SengokuTitleRose}\rule{20mm}{0.70pt}}}%
    \vskip-0.70pt}%
}

\fancypagestyle{sengokufirst}{%
  \fancyhf{}%
  \fancyfoot[C]{\normalfont\SengokuSerif\fontsize{8.2}{10}\selectfont\color{SengokuSlate}\thepage}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\headrule}{}%
  \renewcommand{\footrulewidth}{0pt}%
}
\pagestyle{sengoku}
\renewcommand{\sectionmark}[1]{}
\renewcommand{\subsectionmark}[1]{}
% Keep the user-supplied standard marks stable across bibliography/appendix
% headings, which otherwise replace both sides with "References".
\renewcommand{\@mkboth}[2]{}

% Only the title row is indivisible. The card itself can split across pages.
\newcommand{\Sengoku@titletext}{%
  \centering\normalfont\SengokuSerif\color{SengokuNavy}\bfseries
  \fontsize{15}{18}\selectfont\@title\par
}
\newcommand{\SengokuAbstractBlock}{%
  \begin{tcolorbox}[
    enhanced,breakable,width=.94\textwidth,center,
    colback=SengokuPaper,colframe=SengokuPaper,boxrule=0pt,arc=2mm,
    left=4.8mm,right=4.8mm,top=4.2mm,bottom=4.2mm,boxsep=0pt,
    before skip=0pt,after skip=3mm
  ]
    {\color{SengokuAccent}\rule{\linewidth}{0.45pt}\par}
    \vspace{2.5mm}
    % The logo has zero horizontal width; the title always uses the full row.
    \noindent\SengokuIfTitleLogoTF{%
      \makebox[0pt][l]{%
        \begin{minipage}[c]{.20\linewidth}
          \adjustbox{max width=\linewidth}{\SengokuRenderTitleLogo}
        \end{minipage}}%
    }{}%
    \begin{minipage}[c]{\linewidth}\Sengoku@titletext\end{minipage}\par
    \vspace{2.5mm}
    {\color{SengokuAccent}\rule{\linewidth}{0.45pt}\par}
    \vspace{3.2mm}
    \SengokuRenderAuthorBlock
    \Sengoku@printtitlenotes
    \ifx\Sengoku@abstract\@empty\else
      \vspace{3.0mm}
      {\normalfont\SengokuSerif\fontsize{10.5}{13.8}\selectfont
       \color{SengokuInk}\textbf{Abstract.}\enspace\Sengoku@abstract\par}
    \fi
    \ifx\Sengoku@keywords\@empty\else
      \vspace{1.5mm}
      {\SengokuSerif\itshape\fontsize{10.0}{12.8}\selectfont
       \color{SengokuInk}\textbf{Keywords:}\ \Sengoku@keywords\par}
    \fi
    \SengokuRenderMetadata
  \end{tcolorbox}
}

\renewcommand{\maketitle}{%
  \ifSengoku@titlemade
    \ClassError{Sengoku}{Title has already been typeset}
      {Use \string\maketitle\space only once.}%
  \else
    \global\Sengoku@titlemadetrue
    \thispagestyle{sengokufirst}%
    \begingroup
      \let\thanks\Sengoku@thanks
      \setlength{\parindent}{0pt}%
      \SengokuRenderTopLogoBlock
      \SengokuAbstractBlock
    \endgroup
    \global\let\@thanks\@empty
  \fi
}
\makeatother

% Section hierarchy and page-break protection.
\pretocmd{\section}{\Needspace{6\baselineskip}}{}{}
\pretocmd{\subsection}{\Needspace{4\baselineskip}}{}{}

\titleformat{\section}
  {\normalfont\SengokuSerif\bfseries\fontsize{14.5}{17.2}\selectfont\color{SengokuRose}}
  {\textcolor{SengokuAccent}{\thesection}}
  {0.60em}
  {#1}
  []

\titleformat{name=\section,numberless}
  {\normalfont\SengokuSerif\bfseries\fontsize{14.5}{17.2}\selectfont\color{SengokuRose}}
  {}
  {0pt}
  {#1}
  []

\titleformat{\subsection}
  {\normalfont\SengokuSerif\bfseries\fontsize{11.8}{14.5}\selectfont\color{SengokuNavy}}
  {\textcolor{SengokuAccent}{\thesubsection}}
  {0.55em}
  {#1}
  []

\titleformat{\subsubsection}
  {\normalfont\SengokuSerif\bfseries\fontsize{10.3}{12.8}\selectfont\color{SengokuNavy}}
  {\textcolor{SengokuAccent}{\thesubsubsection}}
  {0.55em}
  {#1}
  []

\titlespacing*{\section}{0pt}{18pt plus 3pt minus 2pt}{6pt}
\titlespacing*{\subsection}{0pt}{12pt plus 2pt minus 1pt}{4pt}
\titlespacing*{\subsubsection}{0pt}{10pt plus 2pt minus 1pt}{3pt}

\DeclareCaptionFont{sengokuserif}{\SengokuSerif}
\captionsetup{
  font={small,sengokuserif},
  labelfont={bf,color=SengokuNavy},
  textfont={color=SengokuSlate},
  figurename=Figure,
  tablename=Table,
  labelsep=period,
  justification=justified,
  singlelinecheck=true,
  skip=5.5pt
}

\setlist[itemize,1]{
  label=\textcolor{SengokuAccent}{\small\raisebox{0.12ex}{\ensuremath{\bullet}}},
  leftmargin=1.55em,
  itemsep=0.18em,
  topsep=0.35em
}
\setlist[enumerate,1]{
  label=\textcolor{SengokuAccent}{\SengokuSerif\bfseries\arabic*.},
  leftmargin=1.75em,
  itemsep=0.18em,
  topsep=0.35em
}

\tcbset{
  sengokucallout/.style={
    enhanced,
    breakable,
    colback=white,
    colframe=SengokuLine,
    coltitle=SengokuNavy,
    fonttitle=\SengokuSerif\bfseries,
    boxrule=0.45pt,
    arc=0mm,
    left=4mm,
    right=4mm,
    top=3mm,
    bottom=3mm
  }
}
\newtcolorbox{sengokubox}[2][]{sengokucallout,title={#2},#1}
\newtcolorbox{sengokunote}[1][]{sengokucallout,title={Research note},#1}

\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}

\makeatletter
\AtBeginDocument{%
  \SengokuSerif\normalsize\color{SengokuInk}%
  \gdef\@author{\SengokuPDFAuthors}%
  \ifx\@pdftitle\@empty\hypersetup{pdftitle={\@title}}\fi
  \ifx\@pdfauthor\@empty\hypersetup{pdfauthor={\SengokuPDFAuthors}}\fi
  \ifx\Sengoku@shorttitle\@empty\let\Sengoku@shorttitle\@title\fi
  \markboth{\Sengoku@runningauthor}{\Sengoku@shorttitle}%
}
\makeatother
