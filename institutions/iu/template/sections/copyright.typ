/// Renders the copyright page with year and author name centered vertically.
///
/// @example
/// ```typ
/// #copyright-page(year: "2026", author: "Jane Doe")
/// ```
/// @endexample
///
/// -> none
#let copyright-page(
  /// Copyright year
  /// -> str
  year: "",
  /// Copyright holder name
  /// -> str
  author: "",
) = {
  pagebreak()
  [
    #v(50%)
    #align(center, text(size: 12pt)[
      \u{a9} #year \
      #author
    ])
  ]
}
