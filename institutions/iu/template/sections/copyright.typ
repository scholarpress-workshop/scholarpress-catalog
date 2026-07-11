#let copyright-page(year: "", author: "") = {
  pagebreak()
  [
    #v(50%)
    #align(center, text(size: 12pt)[
      \u{a9} #year \
      #author
    ])
  ]
}
