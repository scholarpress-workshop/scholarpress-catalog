#import "../styles.typ": iu-heading, iu-body-size, iu-body-font

#let abstract-page(
  heading: "Abstract",
  author: "",
  title: "",
  body: "",
  committee: (),
) = {
  pagebreak()
  [
    #if heading != "" [
      #align(center, text(iu-body-size, upper(heading)))
      #v(12pt)
    ]

    #if author != "" [
      #align(center, text(size: iu-body-size)[#author])
      #v(12pt)
    ]

    #if title != "" [
      #align(center, text(size: iu-body-size, upper(title)))
      #v(12pt)
    ]

    #text(size: iu-body-size)[#body]

    #if committee.len() > 0 [
      #v(24pt)
      #align(right)[
        #for member in committee [
          #v(24pt)
          #line(length: 2.5in)
          #v(4pt)
          #member.name
          #if member.degree != "" [, #member.degree]
          #if member.role != "" [, #member.role]
        ]
      ]
    ]
  ]
}
