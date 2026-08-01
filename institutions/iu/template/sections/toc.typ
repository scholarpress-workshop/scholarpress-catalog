/// Renders the Table of Contents.
/// Entries must be a list of dicts, each with named keys:
///   `level` (int) — heading level (1 = chapter, 2 = section)
///   `title` (str) — heading text
///   `page` (int) — page number
///
/// @example
/// ```typ
/// #toc-page(entries: (
///   (level: 1, title: "Introduction", page: 1),
///   (level: 2, title: "Background", page: 4),
/// ))
/// ```
/// @endexample
///
/// -> none
#let toc-page(
  /// Array of dicts {level: int, title: str, page: int}
  /// -> array
  entries: (),
  /// Page number for the Curriculum Vitae entry. When set, the CV entry
  /// appears with its page number (currently without leader dots).
  /// -> int | none
  cv-page: none,
) = {
  pagebreak()
  [
    #align(center, text(12pt)[TABLE OF CONTENTS])
    #v(12pt)

    #for entry in entries [
      #h(18pt * entry.level)
      #entry.title
      #box(width: 1fr, repeat[.])
      #h(4pt)
      #entry.page
      #v(6pt)
    ]

    #if cv-page != none [
      Curriculum Vitae
    ]
  ]
}
