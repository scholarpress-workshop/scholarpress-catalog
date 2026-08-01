#import "../styles.typ": iu-body-size, school-name, degree-name, department-name, campus-name, grad-month, grad-year

/// Renders the dissertation title page.
/// Reads `document.title` and `document.author.first()` from globals
/// when `title` or `author` are `none`. Set globals in entry.typ:
///   `#set document(title: "My Title", author: "Jane Doe")`
/// Then call `#title-page()` with zero arguments.
/// Custom metadata (school, degree, department, campus, month, year)
/// defaults to values from `styles.typ`.
///
/// ```example
/// #title-page(title: "A Study of X", author: "Jane Doe")
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
  /// School / college name (default: styles.typ school-name)
  /// -> str
  school: school-name,
  /// Degree name (default: styles.typ degree-name)
  /// -> str
  degree: degree-name,
  /// Department name (default: styles.typ department-name)
  /// -> str
  department: department-name,
  /// Campus name (default: styles.typ campus-name)
  /// -> str
  campus: campus-name,
  /// Graduation month (default: styles.typ grad-month)
  /// -> str
  month: grad-month,
  /// Graduation year (default: styles.typ grad-year)
  /// -> str
  year: grad-year,
) = {
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
        Submitted to the faculty of the #school \
        in partial fulfillment of the requirements \
        for the degree \
        #degree \
        in the #department, \
        Indiana University #campus \

        #month #year
      ]
    ]
  }
}
