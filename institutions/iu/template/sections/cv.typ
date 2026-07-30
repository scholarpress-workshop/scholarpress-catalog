#let curriculum-vitae(name: none, body: []) = {
  context {
    let n = if name != none { name } else { document.author.first() }
    pagebreak()
    [
      #set page(numbering: none)
      #align(center, text(12pt)[CURRICULUM VITAE])
      #v(12pt)
      #align(center, text(12pt)[#n])
      #v(24pt)
      #body
    ]
  }
}
