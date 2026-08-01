/// Renders the List of Figures.
/// Entries must be a list of **positional 2-tuples** `(title, page)` — NOT dicts.
///
/// @example
/// ```typ
/// #list-of-figures(entries: (
///   ("Figure 1.1: System Architecture", 15),
/// ))
/// ```
/// @endexample
///
/// -> none
#let list-of-figures(
  /// Array of 2-tuples: (title: str, page: int)
  /// -> array
  entries: (),
) = {
  pagebreak()
  [
    #align(center, text(12pt)[LIST OF FIGURES])
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
