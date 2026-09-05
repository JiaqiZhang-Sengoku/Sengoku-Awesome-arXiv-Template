<h1 align="center">Sengoku Awesome arXiv Template!</h1>

**Sengoku** is a customizable LaTeX template for preprints and technical reports. It combines a colorful title card, flexible logos and author affiliations, and convenient links to code, datasets, and other project resources. With manuscript content separated from layout settings, you can focus on writing and adapt the same design to your own research.

<p align="center">
  <a href="#preview">Preview</a> · <a href="#quick-start">Quick Start</a> · <a href="#acknowledgments">Acknowledgments</a>
</p>

## Preview

<table>
  <tr>
    <th width="45%">First-page preview</th>
    <th width="55%">Sengoku artwork</th>
  </tr>
  <tr>
    <td align="center"><img src="Figures/Figure2.png" alt="First page of the Sengoku template" width="100%"></td>
    <td align="center"><img src="Figures/Figure1.png" alt="Sengoku Awesome arXiv Template promotional artwork" width="100%"></td>
  </tr>
</table>

## Quick Start

1. Upload the project to **Overleaf** and select **pdfLaTeX** as the compiler.
2. Edit `main.tex` to set your title, authors, affiliations, logos, and resource links.
3. Write your manuscript in `Sections/` and put your figures in `Figures/`. Add references to `Reference.bib` and cite them when needed.
4. Click **Recompile** and download your PDF.

For a local build, run `latexmk -pdf main.tex`.

## Acknowledgments

Many thanks to [WangRongsheng/Arxiv-Template](https://github.com/WangRongsheng/Arxiv-Template), the reference template on which Sengoku is based.

<details>
<summary>Attribution & asset notes</summary>

- The inherited template is recorded in the original project under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Sengoku adapts its layout, metadata configuration, and examples.
- Twemoji-derived icons are credited to [Twemoji](https://github.com/twitter/twemoji) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Five icon PDFs were normalized for LaTeX compatibility without changing their artwork.
- The Jiangsu University mark comes from its [official identity resources](https://www.ujs.edu.cn/xxgk/xxbs.htm). Institutional and service marks retain their respective rights; they are not covered by the template license.
- The Sengoku wordmark was supplied by the project author, with no separate artwork license declared. The promotional illustration was generated with OpenAI image tools at the author's direction; its paper and chart elements are illustrative mockups.

</details>

---

<p align="center">If Sengoku helps with your writing, please give this project a ⭐ <strong>Star</strong>!<br>Thank you for your support.</p>
