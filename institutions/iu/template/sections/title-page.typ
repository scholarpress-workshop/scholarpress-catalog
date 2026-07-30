#import "../styles.typ": iu-body-size, school-name, degree-name, department-name, campus-name, grad-month, grad-year

#let title-page(
  title: none,
  author: none,
  school: school-name,
  degree: degree-name,
  department: department-name,
  campus: campus-name,
  month: grad-month,
  year: grad-year,
) = {
  context {
    let t = if title != none { title } else { document.title }
    let a = if author != none { author } else { document.author }
    [
      #set page(numbering: none)
      #align(center, text(size: iu-body-size, weight: "regular", upper(t)))

      #v(1fr)

      #align(center, text(size: iu-body-size)[#a])

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
}
