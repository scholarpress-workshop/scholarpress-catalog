/// Renders the dedication page. Takes a single content block.
///
/// ```example
/// #dedication-page(body: [To my family, for their unwavering support.])
/// ```
///
/// -> none
#let dedication-page(
  /// Dedication text as content block
  /// -> content
  body: [],
) = {
  pagebreak()
  [
    #align(center, text(12pt, upper("Dedication")))
    #v(12pt)
    #body
  ]
}
