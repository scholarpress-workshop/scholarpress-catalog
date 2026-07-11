#let list-of-abbreviations(entries: ()) = {
  pagebreak()
  [
    #align(center, text(12pt)[LIST OF ABBREVIATIONS])
    #v(12pt)
    #for (abbr, meaning) in entries [
      #abbr #h(12pt) #meaning
      #v(4pt)
    ]
  ]
}
