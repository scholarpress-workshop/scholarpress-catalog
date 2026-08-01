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

// IU DISSERTATION TEMPLATE — READ THIS FIRST
//
// CALLING CONVENTION
//   Every section function in this template uses NAMED parameters:
//     #title-page(title: "My Title", author: "Jane Doe")
//   Do NOT use positional calling like `function()[...]` — this fails
//   with "unclosed delimiter".
//
//   Content blocks are passed via `body: [...]` parameters.
//
//   Example entry file wiring:
//     #import "template/template.typ": title-page, dedication-page, toc-page,
//       abstract-page, acknowledgements-page, preface-page, chapter,
//       references-page, curriculum-vitae
//
//     #title-page()
//     #dedication-page(body: [dedication text])
//     #toc-page(entries: toc_data)
//     #abstract-page(body: [abstract text])
//     ...
//
//   $ IN PROSE — $ starts Typst math mode. Dollar amounts, grant IDs, and
//   any prose containing $ must use \$ to escape (e.g., \$17 million).
//
// GLOBAL METADATA
//   Set once at top: #set document(title: [...], author: "Name")
//   Custom metadata (committee, dates, school, etc.): #let vars in styles.typ
//   Sections read globals automatically — no per-section parameters needed:
//     #title-page()  ← zero-arg call reads document metadata
//
// PAGE NUMBERING
//   Front matter (i=): set page(numbering: "i") at top level.
//   Chapter body (1=): chapter() sets page(numbering: "1") internally.
//   Back matter: references & appendices MUST set their own numbering
//   or they inherit the top-level "i" (Roman numerals).
//
// HEADING HIERARCHY
//   Chapter title: rendered by chapter(). Agent writes `==` (H2) and
//   `===` (H3) in chapter body. H2: centered+underlined. H3: left-aligned
//   +underlined. Numbered "1.1", "1.1.1". Front matter uses Typst defaults.
//
// $ IN PROSE
//   $ starts math mode. Escape with \$ in body text (e.g., \$17 million).
//
// CHAPTER PER-FILE CONVENTION
//   Each chapter is one file in chapters/: ch01.typ → #let name = [...]
//   template.typ imports: #import "chapters/ch01.typ": ch-name
//   Then calls: #chapter(number: "1", title: "Title", body: ch-name, first: true)
//
// ORDER
//   Required: title-page, acceptance-page, abstract-page, chapters.
//   Optional: copyright, dedication, acknowledgements, preface, toc, lists.
//   End matter: references-page, appendices, curriculum-vitae.

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
