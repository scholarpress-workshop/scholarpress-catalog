/// Renders the List of Pictures.
/// Entries must be a list of **positional 2-tuples** `(title, page)` — NOT dicts.
///
/// ```example
/// #list-of-pictures(entries: (
///   ("Photo 1: Study Site", 30),
/// ))
/// ```
///
/// -> none
#let list-of-pictures(
  /// Array of 2-tuples: (title: str, page: int)
  /// -> array
  entries: (),
) = {
  pagebreak()
  [
    #align(center, text(12pt)[LIST OF PICTURES])
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
