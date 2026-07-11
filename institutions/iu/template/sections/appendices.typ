#let appendices-section() = {
  pagebreak()
  [
    #v(1fr)
    #align(center, text(12pt, upper("Appendices")))
    #v(2fr)
  ]
}

#let appendix(label: "A", title: "", body: []) = {
  pagebreak()
  [
    #v(1fr)
    #align(center, text(12pt, upper("APPENDIX " + label))) \
    #align(center, text(12pt, upper(title)))
    #v(2fr)
  ]
  pagebreak()
  body
}
