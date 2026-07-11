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

#let iu-heading(level, title) = {
  if level == 1 {
    align(center, underline(text(title)))
    v(12pt)
  } else if level == 2 {
    underline(text(title))
    v(6pt)
  } else {
    text(style: "italic", title)
    v(6pt)
  }
}

#let iu-chapter-heading(title) = {
  pagebreak()
  align(center, text(iu-heading-size, upper(title)))
  v(24pt)
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
