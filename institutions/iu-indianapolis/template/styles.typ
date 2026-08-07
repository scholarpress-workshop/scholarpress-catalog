#let iu-body-font = "Libertinus Serif"
#let iu-body-size = 12pt
#let iu-heading-font = "Libertinus Serif"
#let iu-heading-size = 12pt
#let iu-line-spacing = 2.0

#let iu-margin-left = 1.25in
#let iu-margin-right = 1.25in
#let iu-margin-top = 1in
#let iu-margin-bottom = 1in

#let iu-page-setup(body) = {
  set page(
    margin: (
      top: iu-margin-top,
      bottom: iu-margin-bottom,
      left: iu-margin-left,
      right: iu-margin-right,
    ),
    numbering: "1",
  )
  set text(font: iu-body-font, size: iu-body-size)
  set par(leading: 0.65em * iu-line-spacing)
  body
}

#let number-to-word(n) = {
  let words = (
    "ONE",
    "TWO",
    "THREE",
    "FOUR",
    "FIVE",
    "SIX",
    "SEVEN",
    "EIGHT",
    "NINE",
    "TEN",
    "ELEVEN",
    "TWELVE",
    "THIRTEEN",
    "FOURTEEN",
    "FIFTEEN",
  )
  let i = int(n)
  if i >= 1 and i <= words.len() {
    words.at(i - 1)
  } else {
    n
  }
}

#let iu-toc-entry(title, page) = {
  title
  box(width: 1fr, repeat[.])
  h(4pt)
  page
}

#let iu-reference-style(body) = {
  set par(leading: 1em + 0pt)
  set text(size: iu-body-size)
  body
}

// INSTITUTION METADATA — set these once; all section functions read them.
//   committee-members = ((name: "...", degree: "...", role: "..."), ...)
//   defense-date = "May 2026"
//   grad-month / grad-year
// Canonical title-page values are exported below for extraction and generation
// guidance. Custom strings remain valid when a program is not listed.
//
// number-to-word(n) — converts "1" → "ONE" for spelled-out chapter titles.
#let canonical-degrees = (
  "Master of Arts",
  "Master of Science",
  "Master of Science in Forensic Science",
  "Doctor of Philosophy",
)

#let canonical-departments = (
  "in the School of Dentistry",
  "in the School of Education",
  "in the School of Health and Human Sciences",
  "in the Herron School of Art and Design",
  "in the School of Nursing",
  "in the School of Social Work",
  "in the Lilly Family School of Philanthropy",
  "in the Luddy School of Informatics, Computing, and Engineering",
  "in the Richard M. Fairbanks School of Public Health",
  "in the Department of Anatomy, Cell Biology and Physiology",
  "in the Department of Anthropology",
  "in the Department of Biochemistry and Molecular Biology",
  "in the Department of Biology",
  "in the Department of Biostatistics and Health Data Science",
  "in the Department of Chemistry and Chemical Biology",
  "in the Department of Communication Studies",
  "in the Department of Earth and Environmental Sciences",
  "in the Department of Economics",
  "in the Department of English",
  "in the Department of Forensic Science",
  "in the Department of Geography",
  "in the Department of History",
  "in the Department of Journalism",
  "in the Department of Mathematical Sciences",
  "in the Department of Medical and Molecular Genetics",
  "in the Department of Microbiology and Immunology",
  "in the Department of Museum Studies",
  "in the Department of Pathology",
  "in the Department of Pharmacology and Toxicology",
  "in the Department of Philosophy",
  "in the Department of Physics",
  "in the Department of Psychology",
  "in the Department of Sociology",
  "in the Department of World Languages and Cultures",
  "in the Program of American Studies",
  "in the Program of Medical Neuroscience",
  "in the Program of Musculoskeletal Health Science",
  "in the Program of Translational Cancer Biology",
)

#let committee-members = ()
#let defense-date = ""
#let grad-month = ""
#let grad-year = ""
