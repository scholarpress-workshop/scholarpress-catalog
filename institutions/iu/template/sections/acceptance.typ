#import "../styles.typ": iu-body-size

#let acceptance-page(
  committee: (),
  defense_date: "",
) = {
  pagebreak()
  [
    #align(center)[
      Accepted by the graduate faculty, Indiana University, in partial
      fulfillment of the requirements for the degree of #emph[_Doctor of Philosophy_].
    ]



    Doctoral Committee



    #for (i, member) in committee.enumerate() [
      #align(right)[
        #v(24pt)
        #line(length: 2.5in)
        #v(4pt)
        #member.name
        #if member.degree != "" [, #member.degree]
        #if member.role != "" [, #member.role]
      ]
      #if i == 1 and defense_date != "" [
        Defense Date: #defense_date
      ]
    ]
  ]
}
