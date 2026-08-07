#import "../styles.typ": iu-body-size, iu-body-font, committee-members

/// Renders the abstract page with title, author, body text, and committee lines.
/// Falls back to `document.title` and `document.author.first()` when title/author
/// are `none`. Set globals in entry.typ: `#set document(title: "...", author: "...")`
///
/// ```example
/// #abstract-page(
///   heading: "Abstract",
///   body: [This dissertation examines...],
/// )
/// ```
///
/// -> none
#let abstract-page(
  /// Abstract heading text (default: "Abstract")
  /// -> str
  heading: "Abstract",
  /// Author name (falls back to document.author.first())
  /// -> str | none
  author: none,
  /// Dissertation title (falls back to document.title)
  /// -> str | none
  title: none,
  /// Abstract body text
  /// -> str
  body: "",
  /// Committee members: list of dicts {name: str, degree: str, role: str}
  /// -> array
  committee: committee-members,
) = {
  context {
    let a = if author != none { author } else { document.author.first() }
    let t = if title != none { title } else { document.title }
    pagebreak()
    [
      #if heading != "" [
        #align(center, text(iu-body-size, upper(heading)))
        #v(12pt)
      ]

      #if a != "" [
        #align(center, text(size: iu-body-size)[#a])
        #v(12pt)
      ]

      #if t != "" [
        #align(center, text(size: iu-body-size, upper(t)))
        #v(12pt)
      ]

      #text(size: iu-body-size)[#body]

      #if committee.len() > 0 [
        #v(24pt)
        #align(right)[
          #for member in committee [
            #v(24pt)
            #line(length: 2.5in)
            #v(4pt)
            #member.name
            #if member.degree != "" [, #member.degree]
            #if member.role != "" [, #member.role]
          ]
        ]
      ]
    ]
  }
}
