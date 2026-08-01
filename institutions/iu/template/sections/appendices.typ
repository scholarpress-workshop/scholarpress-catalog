/// Renders the appendices divider page. Call once before individual appendix pages.
///
/// -> none
#let appendices-section() = {
  pagebreak()
  [
    #v(1fr)
    #align(center, text(12pt, upper("Appendices")))
    #v(2fr)
  ]
}

/// Renders an individual appendix with a letter label and title.
///
/// ```example
/// #appendix(label: "A", title: "Survey Instrument", body: [Survey details...])
/// ```
///
/// -> none
#let appendix(
  /// Appendix letter label (e.g., "A", "B")
  /// -> str
  label: "A",
  /// Appendix title text
  /// -> str
  title: "",
  /// Appendix body as content block
  /// -> content
  body: [],
) = {
  pagebreak()
  [
    #v(1fr)
    #align(center, text(12pt, upper("APPENDIX " + label))) \
    #align(center, text(12pt, upper(title)))
    #v(2fr)
  ]
  pagebreak()
  body
}
