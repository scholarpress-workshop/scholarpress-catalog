#import "../styles.typ": iu-body-size, iu-body-font, number-to-word

/// Renders a dissertation chapter.
///
/// Heading hierarchy (scoped to chapter body, front matter unaffected):
///   == H2 — centered, underlined, numbered "1.1", regular weight
///   === H3 — left-aligned, underlined, numbered "1.1.1", regular weight
///
/// Use `first: true` on the first body chapter to reset page numbering
/// from Roman numerals (front matter) to Arabic (chapter body).
///
/// All parameters are NAMED. Call as:
///   #chapter(number: "1", title: "Introduction", body: intro-content, first: true)
#let chapter(number: "", title: "", body: [], first: false) = {
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
