#import "../styles.typ": grad-month, grad-year, iu-body-size

/// Renders the dissertation title page.
/// Reads `document.title` and `document.author.first()` from globals
/// when `title` or `author` are `none`. Set globals in entry.typ:
///   `#set document(title: "My Title", author: "Jane Doe")`
/// Then call `#title-page(degree: ..., department: ...)` with explicit program metadata.
/// Degree and department are required. Department values include their
/// grammatical prefix and are rendered unchanged.
/// Month and year default to values from `styles.typ`.
///
/// ```example
/// #title-page(
///   title: "A Study of X",
///   author: "Jane Doe",
///   degree: "Doctor of Philosophy",
///   department: "in the Program of American Studies",
/// )
/// ```
///
/// -> none
#let title-page(
  /// Dissertation title (falls back to document.title)
  /// -> str | none
  title: none,
  /// Author name (falls back to document.author.first())
  /// -> str | none
  author: none,
  /// Formal degree name.
  /// -> str
  degree: none,
  /// Department or program, including its grammatical prefix.
  /// -> str
  department: none,
  /// Graduation month (default: styles.typ grad-month)
  /// -> str
  month: grad-month,
  /// Graduation year (default: styles.typ grad-year)
  /// -> str
  year: grad-year,
) = {
  assert(degree != none, message: "title-page requires degree")
  assert(department != none, message: "title-page requires department")
  context {
    let t = if title != none { title } else { document.title }
    let a = if author != none { author } else { document.author.first() }
    [
      #set page(numbering: none)
      #align(center, text(size: iu-body-size, weight: "regular", upper(t)))

      #v(1fr)

      #align(center, text(size: iu-body-size)[#a])

      #v(1fr)

      #align(center)[
        Submitted to the faculty of the Indianapolis Graduate School \
        in partial fulfillment of the requirements \
        for the degree \
        #degree \
        #department \
        Indiana University \
        \

        #month #year
      ]
    ]
  }
}
