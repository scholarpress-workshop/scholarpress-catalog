/// Renders the preface page.
///
/// ```example
/// #preface-page(title: "Author's Preface", body: [This work began...])
/// ```
///
/// -> none
#let preface-page(
  /// Page heading (default: "Preface")
  /// -> str
  title: "Preface",
  /// Preface text as content block
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
