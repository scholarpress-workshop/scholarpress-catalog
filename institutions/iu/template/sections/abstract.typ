#import "../styles.typ": iu-body-size, iu-body-font, committee-members

#let abstract-page(
  heading: "Abstract",
  author: none,
  title: none,
  body: "",
  committee: committee-members,
) = {
  context {
    let a = if author != none { author } else { document.author.first() }
    let t = if title != none { title } else { document.title }
    pagebreak()
    [
      #if heading != "" [
        #align(center, text(iu-body-size, upper(heading)))
        #v(12pt)
      ]

      #if a != "" [
        #align(center, text(size: iu-body-size)[#a])
        #v(12pt)
      ]

      #if t != "" [
        #align(center, text(size: iu-body-size, upper(t)))
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
}
