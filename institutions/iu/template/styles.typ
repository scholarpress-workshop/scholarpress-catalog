#let iu-body-font = "Libertinus Serif"
#let iu-body-size = 12pt
#let iu-heading-font = "Libertinus Serif"
#let iu-heading-size = 12pt
#let iu-line-spacing = 2.0

#let iu-margin-left = 1.25in
#let iu-margin-right = 1.25in
#let iu-margin-top = 1in
#let iu-margin-bottom = 1in

#let iu-page-setup(body) = {
  set page(
    margin: (
      top: iu-margin-top,
      bottom: iu-margin-bottom,
      left: iu-margin-left,
      right: iu-margin-right,
    ),
    numbering: "1",
  )
  set text(font: iu-body-font, size: iu-body-size)
  set par(leading: 0.65em * iu-line-spacing)
  body
}

#let number-to-word(n) = {
  let words = (
    "ONE", "TWO", "THREE", "FOUR", "FIVE",
    "SIX", "SEVEN", "EIGHT", "NINE", "TEN",
    "ELEVEN", "TWELVE", "THIRTEEN", "FOURTEEN", "FIFTEEN",
  )
  let i = int(n)
  if i >= 1 and i <= words.len() {
    words.at(i - 1)
  } else {
    n
  }
}

#let iu-toc-entry(title, page) = {
  title
  box(width: 1fr, repeat[.])
  h(4pt)
  page
}

#let iu-reference-style(body) = {
  set par(leading: 1em + 0pt)
  set text(size: iu-body-size)
  body
}

// Global metadata — defined once, read by all section functions.
#let committee-members = ()
#let defense-date = ""
#let school-name = "Indiana University"
#let degree-name = "Doctor of Philosophy"
#let department-name = ""
#let campus-name = ""
#let grad-month = ""
#let grad-year = ""
