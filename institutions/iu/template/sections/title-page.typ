#import "../styles.typ": iu-body-size

#let title-page(
  title: "",
  author: "",
  school: "",
  degree: "Doctor of Philosophy",
  department: "",
  campus: "",
  month: "",
  year: "",
) = {
  [
    #set page(numbering: none)
    #align(center, text(size: iu-body-size, weight: "regular", upper(title)))

    #v(1fr)

    #align(center, text(size: iu-body-size)[#author])

    #v(1fr)

    #align(center)[
      Submitted to the faculty of the #school \
      in partial fulfillment of the requirements \
      for the degree \
      #degree \
      in the #department, \
      Indiana University #campus \

      #month #year
    ]
  ]
}
