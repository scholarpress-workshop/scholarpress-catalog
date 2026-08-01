#import "../styles.typ": iu-body-size, committee-members, defense-date

/// Renders the acceptance page with committee signatures.
/// Committee members and defense date default to values from `styles.typ`.
/// Override per-workspace via `data.json`.
///
/// @example
/// ```typ
/// #acceptance-page(
///   committee: ((name: "Dr. Smith", degree: "Ph.D.", role: "Chair"),),
///   defense_date: "May 2026",
/// )
/// ```
/// @endexample
///
/// -> none
#let acceptance-page(
  /// Committee members: list of dicts {name: str, degree: str, role: str}
  /// -> array
  committee: committee-members,
  /// Defense date string (e.g., "May 2026")
  /// -> str
  defense_date: defense-date,
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
