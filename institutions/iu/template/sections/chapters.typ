#import "../styles.typ": iu-body-size, iu-body-font, number-to-word

/// Renders a dissertation chapter with proper heading hierarchy.
///
/// Heading hierarchy (scoped to chapter body, front matter unaffected):
///   =  (H1) — chapter title, centered, underlined, uppercase, spelled-out number
///   == (H2) — centered, underlined, numbered "1.1", regular weight
///   === (H3) — left-aligned, underlined, numbered "1.1.1", regular weight
///
/// Use `first: true` on the first body chapter to:
///   - Reset page counter to 1 (`counter(page).update(1)`)
///   - Switch page numbering from Roman (front matter) to Arabic (body)
///
/// ```example
/// #chapter(number: "1", title: "Introduction", body: intro-body, first: true)
/// ```
///
/// -> none
#let chapter(
  /// Chapter number as string (e.g., "1", "2"). Spelled out in heading.
  /// -> str
  number: "",
  /// Chapter title text
  /// -> str
  title: "",
  /// Chapter body as content block (write `==` and `===` headings inside)
  /// -> content
  body: [],
  /// Set true for first body chapter to reset page numbering to Arabic
  /// -> bool
  first: false,
) = {
  pagebreak()

  [
    #set heading(numbering: "1.1")
    #counter(heading).update(0)
    #if first {
      counter(page).update(1)
    }
    #set page(numbering: "1")

    // Chapter title — show rule only applies styling, doesn't replace heading
    #show heading.where(level: 1): it => {
      align(center, text(
        size: iu-body-size,
        weight: "regular",
        upper(it.body),
      ))
      v(24pt)
    }

    // H2 (`==`): centered, underlined, regular weight, body size
    #show heading.where(level: 2): it => {
      align(center, text(
        weight: "regular",
        size: iu-body-size,
        underline(it),
      ))
      v(12pt)
    }

    // H3 (`===`): left-aligned, underlined, regular weight, body size
    #show heading.where(level: 3): it => {
      text(
        weight: "regular",
        size: iu-body-size,
        underline(it),
      )
      v(6pt)
    }

    // Figure/equation show rules
    #set figure(gap: 2em)
    #show figure.caption: it => {
      set text(size: iu-body-size)
      it
    }
    #show math.equation: it => {
      if it.has("label") {
        math.equation(
          block: true,
          numbering: "(1)",
          it,
        )
      } else {
        it
      }
    }
    #show ref: it => {
      let el = it.element
      if el != none and el.func() == math.equation {
        let eq = counter(math.equation).at(el.location()).at(0) + 1
        link(
          el.location(),
          [Eq.~#eq],
        )
      } else {
        it
      }
    }

    // Chapter title as a real heading (level 1). The show rule above
    // styles it; the counter advances. Body headings (==/===) inherit
    // the numbering and show rules.
    = #upper("chapter " + number-to-word(number) + "\n" + title)

    #body
  ]
}
