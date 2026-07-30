// Zero-arg test: all metadata set via globals, no per-section overrides.
// Compile with: typst compile test-global.typ

#import "styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/copyright.typ": copyright-page
#import "sections/dedication.typ": dedication-page
#import "sections/acknowledgements.typ": acknowledgements-page
#import "sections/preface.typ": preface-page
#import "sections/abstract.typ": abstract-page
#import "sections/toc.typ": toc-page
#import "sections/chapters.typ": chapter
#import "sections/references.typ": references-page
#import "sections/cv.typ": curriculum-vitae

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
#copyright-page()
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
  = Background
  This is a test chapter.

  == Subsection
  More content here.
], first: true)
#chapter(number: "2", title: "Methods", body: [
  = Experimental Design
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
