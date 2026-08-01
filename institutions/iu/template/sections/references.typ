/// Renders the References page.
/// Entries are **raw content** — NOT tuples or dicts.
/// Pass citation text directly as a content block.
///
/// @example
/// ```typ
/// #references-page(entries: [
///   Author, A. (2020). Title of work. *Journal*, 12(3), 45--67.
///
///   Author, B. (2021). Another title. *Publisher*.
/// ])
/// ```
/// @endexample
///
/// -> none
#let references-page(
  /// Raw content block containing formatted reference text
  /// -> content
  entries: [],
) = {
  pagebreak()
  [
    #set page(numbering: "1")
    #align(center, text(12pt)[REFERENCES])
    #v(12pt)
    #set par(leading: 1em + 0pt)
    #entries
  ]
}
