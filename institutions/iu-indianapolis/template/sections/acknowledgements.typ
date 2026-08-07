/// Renders the acknowledgements page.
///
/// ```example
/// #acknowledgements-page(body: [I would like to thank...])
/// ```
///
/// -> none
#let acknowledgements-page(
  /// Page heading (default: "Acknowledgements")
  /// -> str
  title: "Acknowledgements",
  /// Acknowledgements text as content block
  /// -> content
  body: [],
) = {
  pagebreak()
  [
    #align(center, text(12pt, upper(title)))
    #v(12pt)
    #body
  ]
}
