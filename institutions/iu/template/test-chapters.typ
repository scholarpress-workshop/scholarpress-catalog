// Test: chapter file import convention.
// Compile with: typst compile test-chapters.typ

#import "styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/chapters.typ": chapter
#import "chapters/ch01.typ": historical-context

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

#set document(title: [Test: Per-File Chapter Convention], author: "Test Author")

#let committee-members = ((name: "Dr. Test Chair", degree: "Ph.D.", role: "Chair"))
#let defense-date = "July 2026"
#let campus-name = "Bloomington"
#let department-name = "Test Department"

#title-page()
#acceptance-page()

// Chapter imported from chapters/ch01.typ
#chapter(
  number: "1",
  title: "Historical Context",
  body: historical-context,
  first: true,
)
