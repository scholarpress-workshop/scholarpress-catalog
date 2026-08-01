/// Renders the Curriculum Vitae page. Sets `page(numbering: none)` to suppress
/// page numbers on CV pages.
///
/// ```example
/// #curriculum-vitae(body: [
///   == Education
///   Ph.D. Candidate, Indiana University, 2026
/// ])
/// ```
///
/// -> none
#let curriculum-vitae(
  /// Name (falls back to document.author.first())
  /// -> str | none
  name: none,
  /// CV content as content block
  /// -> content
  body: [],
) = {
  context {
    let n = if name != none { name } else { document.author.first() }
    pagebreak()
    [
      #set page(numbering: none)
      #align(center, text(12pt)[CURRICULUM VITAE])
      #v(12pt)
      #align(center, text(12pt)[#n])
      #v(24pt)
      #body
    ]
  }
}
