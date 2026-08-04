// Zero-arg test: all metadata set via globals, no per-section overrides.
// Compile with: typst compile test-global.typ
//
// #set SCOPING NOTE: Typst #set is module-scoped. Section functions imported
// from template.typ capture the template's own #set rules, not the entry
// file's. The #set page(...) and #set text(...) below are redundant with
// what template.typ already sets — they're harmless but unnecessary.
// Content blocks passed via body: [...] ARE styled by this file's #set text
// because they're created here, not in template.typ.

#import "../template/styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "../template/sections/title-page.typ": title-page
#import "../template/sections/acceptance.typ": acceptance-page
#import "../template/sections/copyright.typ": copyright-page
#import "../template/sections/dedication.typ": dedication-page
#import "../template/sections/acknowledgements.typ": acknowledgements-page
#import "../template/sections/preface.typ": preface-page
#import "../template/sections/abstract.typ": abstract-page
#import "../template/sections/toc.typ": toc-page
#import "../template/sections/chapters.typ": chapter
#import "../template/sections/references.typ": references-page
#import "../template/sections/cv.typ": curriculum-vitae

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

#set document(
  title: [A Study of Test-Driven Template Parameters],
  author: "Jane A. Doe",
)

#let committee-members = (
  (name: "Dr. Alice Smith", degree: "Ph.D.", role: "Chair"),
  (name: "Dr. Bob Jones", degree: "Ph.D.", role: ""),
  (name: "Dr. Carol Lee", degree: "Ph.D.", role: ""),
  (name: "Dr. David Brown", degree: "Ed.D.", role: ""),
)
#let defense-date = "May 2026"
#let school-name = "Indiana University"
#let degree-name = "Doctor of Philosophy"
#let department-name = "Computer Science"
#let campus-name = "Bloomington"
#let grad-month = "May"
#let grad-year = "2026"

#title-page()
#acceptance-page()
#copyright-page(year: grad-year, author: "Jane A. Doe")
#dedication-page(body: [To my family.])
#acknowledgements-page(body: [I would like to thank...])
#preface-page(body: [This dissertation explores...])
#abstract-page(
  body: [
    The field of test-driven template parameters has long been neglected...
  ],
)
#toc-page()
#chapter(number: "1", title: "Introduction", body: [
  == Background
  This is a test chapter.

  === Subsection
  More content here.
], first: true)
#chapter(number: "2", title: "Methods", body: [
  == Experimental Design
  The experiment was designed to test...
])
#references-page(entries: [
  - Smith, A. (2025). *On Template Design*. Journal of Typography, 12(3), 45-67.
])
#curriculum-vitae(body: [
  *Education*

  - Ph.D., Computer Science, Indiana University, 2026
  - M.S., Computer Science, State University, 2022
  - B.S., Mathematics, State University, 2020
])
