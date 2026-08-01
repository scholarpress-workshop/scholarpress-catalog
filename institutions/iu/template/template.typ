/// IU Dissertation Template — Global Metadata and Conventions.
///
/// = Page Numbering
/// Front matter uses Roman numerals (i, ii, iii...) set at template level:
///   `#set page(numbering: "i")`
/// Chapter body switches to Arabic (1, 2, 3...) via `chapter(first: true)` which
/// calls `counter(page).update(1)` and `#set page(numbering: "1")`.
/// Back matter (references, appendices) must set their own numbering or they
/// inherit the top-level Roman numeral.
///
/// = Heading Hierarchy
/// Chapter title: rendered by `chapter()` as `=` (H1).
/// Inside chapter body write `==` (H2 — centered, underlined, numbered "1.1")
/// and `===` (H3 — left-aligned, underlined, numbered "1.1.1").
/// Front matter uses Typst defaults.
///
/// = Dollar Signs
/// `$` starts math mode in Typst prose. Escape with `\$` (e.g., `\$17 million`).
///
/// = data.json
/// Write structured data to `<workspace>/data.json` before running `compile_typst`.
/// The template reads it with `json("data.json")` or `read("data.json")`.
///
/// = Chapter Per-File Convention
/// Each chapter is one file in `chapters/`:
///   `ch01.typ`: `#let ch-name = [...]`
///   `template.typ` imports: `#import "chapters/ch01.typ": ch-name`
///   Then calls: `#chapter(number: "1", title: "Title", body: ch-name, first: true)`

#import "styles.typ": iu-page-setup, iu-margin-top, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/copyright.typ": copyright-page
#import "sections/dedication.typ": dedication-page
#import "sections/acknowledgements.typ": acknowledgements-page
#import "sections/preface.typ": preface-page
#import "sections/abstract.typ": abstract-page
#import "sections/toc.typ": toc-page
#import "sections/lot.typ": list-of-tables
#import "sections/lof.typ": list-of-figures
#import "sections/lop.typ": list-of-pictures
#import "sections/loa.typ": list-of-abbreviations
#import "sections/chapters.typ": chapter
#import "sections/references.typ": references-page
#import "sections/appendices.typ": appendix
#import "sections/cv.typ": curriculum-vitae

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

#set document(
  title: [],
  author: "",
)
