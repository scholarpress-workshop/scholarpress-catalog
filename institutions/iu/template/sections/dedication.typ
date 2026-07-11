#let dedication-page(body: []) = {
  pagebreak()
  [
    #align(center, text(12pt, upper("Dedication")))
    #v(12pt)
    #body
  ]
}
