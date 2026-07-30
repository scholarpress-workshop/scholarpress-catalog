#import "../styles.typ": iu-body-size, iu-body-font, number-to-word

#let chapter(number: "", title: "", body: [], first: false) = {
  pagebreak()
  [
    #if first {
      counter(page).update(1)
    }
    #set page(numbering: "1")

    // Heading numbering: `==` gets "1.1", `===` gets "1.1.1"
    #set heading(numbering: "1.1")
    counter(heading).update(0)

    // H2 (`==`): centered, title case, underlined, regular weight, single line
    #show heading.where(level: 2): it => {
      align(
        center,
        underline(
          text(
            size: iu-body-size,
            font: iu-body-font,
            weight: "regular",
            it.body,
          ),
        ),
      )
      v(12pt)
    }

    // H3 (`===`): left-aligned, title case, underlined, regular weight, single line
    #show heading.where(level: 3): it => {
      underline(
        text(
          size: iu-body-size,
          font: iu-body-font,
          weight: "regular",
          it.body,
        ),
      )
      v(6pt)
    }

    // Figure/equation show rules (unchanged from original)
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

    // Chapter title — spelled-out number, centered, all caps, regular weight
    #align(center)[
      #text(size: iu-body-size, weight: "regular", upper(
        "CHAPTER " + number-to-word(number)
      )) \
      #text(size: iu-body-size, weight: "regular", upper(title))
    ]
    #v(24pt)

    // Advance heading counter so `==` in body gets "1.1" (not just "1")
    counter(heading).step()

    #body
  ]
}
