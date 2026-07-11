#let curriculum-vitae(name: "", body: []) = {
  pagebreak()
  [
    #set page(numbering: none)
    #align(center, text(12pt)[CURRICULUM VITAE])
    #v(12pt)
    #align(center, text(12pt)[#name])
    #v(24pt)
    #body
  ]
}
