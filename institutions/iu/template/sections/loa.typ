/// Renders the List of Abbreviations.
/// Entries must be a list of **positional 2-tuples** `(abbreviation, meaning)` — NOT dicts.
///
/// ```example
/// #list-of-abbreviations(entries: (
///   ("API", "Application Programming Interface"),
///   ("DOI", "Digital Object Identifier"),
/// ))
/// ```
///
/// -> none
#let list-of-abbreviations(
  /// Array of 2-tuples: (abbreviation: str, meaning: str)
  /// -> array
  entries: (),
) = {
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
