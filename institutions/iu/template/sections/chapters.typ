#import "../styles.typ": iu-body-size

#let chapter(number: "", title: "", body: [], first: false) = {
  pagebreak()
  [
    #if first {
      counter(page).update(1)
    }
    #set page(numbering: "1")

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

    #align(center)[
      #text(iu-body-size, upper("CHAPTER " + number)) \
      #text(iu-body-size, upper(title))
    ]
    #v(24pt)
    #body
  ]
}
