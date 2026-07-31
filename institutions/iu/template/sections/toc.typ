// TOC ENTRIES — array of dictionaries used in #toc-page(entries: ...)
//   ((level: 1, title: "Introduction", page: 1),
//    (level: 2, title: "Background", page: 4), ...)
//   .level — integer heading level (1 = chapter, 2 = section)
//   .title — string heading text
//   .page  — integer page number
#let toc-page(
  entries: (),
  cv-page: none,
) = {
  pagebreak()
  [
    #align(center, text(12pt)[TABLE OF CONTENTS])
    #v(12pt)

    #for entry in entries [
      #h(18pt * entry.level)
      #entry.title
      #box(width: 1fr, repeat[.])
      #h(4pt)
      #entry.page
      #v(6pt)
    ]

    #if cv-page != none [
      Curriculum Vitae
    ]
  ]
}
