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
