/// Renders the List of Tables.
/// Entries must be a list of **positional 2-tuples** `(title, page)` — NOT dicts.
///
/// @example
/// ```typ
/// #list-of-tables(entries: (
///   ("Table 1.1: Sample Results", 23),
///   ("Table 2.1: Summary Statistics", 47),
/// ))
/// ```
/// @endexample
///
/// -> none
#let list-of-tables(
  /// Array of 2-tuples: (title: str, page: int)
  /// -> array
  entries: (),
) = {
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
