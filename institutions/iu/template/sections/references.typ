#let references-page(entries: []) = {
  pagebreak()
  [
    #set page(numbering: "1")
    #align(center, text(12pt)[REFERENCES])
    #v(12pt)
    #set par(leading: 1em + 0pt)
    #entries
  ]
}
