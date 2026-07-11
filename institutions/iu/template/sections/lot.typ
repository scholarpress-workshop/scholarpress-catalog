#let list-of-tables(entries: ()) = {
  pagebreak()
  [
    #align(center, text(12pt)[LIST OF TABLES])
    #v(12pt)
    #for (title, page) in entries [
      #title
      #box(width: 1fr, repeat[.])
      #h(4pt)
      #page
      #v(4pt)
    ]
  ]
}
