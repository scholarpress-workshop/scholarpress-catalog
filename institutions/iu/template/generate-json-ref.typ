#import "@preview/tidy:0.4.3": parse-module

#let section-files = (
  ("title-page", "sections/title-page.typ"),
  ("acceptance-page", "sections/acceptance.typ"),
  ("copyright-page", "sections/copyright.typ"),
  ("dedication-page", "sections/dedication.typ"),
  ("acknowledgements-page", "sections/acknowledgements.typ"),
  ("preface-page", "sections/preface.typ"),
  ("abstract-page", "sections/abstract.typ"),
  ("toc-page", "sections/toc.typ"),
  ("list-of-tables", "sections/lot.typ"),
  ("list-of-figures", "sections/lof.typ"),
  ("list-of-pictures", "sections/lop.typ"),
  ("list-of-abbreviations", "sections/loa.typ"),
  ("chapter", "sections/chapters.typ"),
  ("references-page", "sections/references.typ"),
  ("appendices-section", "sections/appendices.typ"),
  ("curriculum-vitae", "sections/cv.typ"),
)

#let all-functions = ()

#for (_, path) in section-files {
  let file-content = read(path)
  let docs = parse-module(file-content)
  for func in docs.functions {
    func.file = path
    all-functions.push(func)
  }
}

#let functions = ()
#for func in all-functions {
  let params = ()
  for (name, info) in func.args.pairs() {
    let param-type = if info.types.len() > 0 {
      info.types.join(" | ")
    } else {
      "any"
    }
    let default = if "default" in info {
      info.default
    } else {
      none
    }
    params.push((
      name: name,
      type: param-type,
      default: default,
      description: info.description,
    ))
  }

  let sig = func.name + "("
  let first = true
  for (name, info) in func.args.pairs() {
    if not first { sig += ", " }
    first = false
    sig += name + ": "
    if "default" in info {
      sig += info.default
    } else {
      sig += info.types.first()
    }
  }
  sig += ")"

  functions.push((
    name: func.name,
    file: func.file,
    signature: sig,
    description: func.description,
    params: params,
  ))
}

#metadata(json.encode((
  profile: "institutions/iu",
  globals: (
    (
      key: "page_numbering",
      description: "Front matter uses Roman numerals (\"i\") set at template level. Chapter body switches to Arabic (\"1\") via `chapter(first: true)` which calls `counter(page).update(1)` and `set page(numbering: \"1\")`."
    ),
    (
      key: "data_json",
      description: "Write structured data to <workspace>/data.json before compile. Template reads via `json(\"data.json\")` or `read(\"data.json\")`."
    ),
    (
      key: "heading_hierarchy",
      description: "chapter() renders = (H1). Inside chapter body: == (H2: centered, underlined, numbered 1.1) and === (H3: left-aligned, underlined, numbered 1.1.1)."
    ),
    (
      key: "dollar_signs",
      description: "$ starts math mode in Typst prose. Use \\$ to escape (e.g., \\$17 million)."
    ),
    (
      key: "chapter_per_file",
      description: "Each chapter is one file in `chapters/`. ch01.typ exports `#let ch-name = [...]`. Entry file imports and calls `#chapter(number: \"1\", title: \"Title\", body: ch-name, first: true)`."
    ),
  ),
  functions: functions,
))) <ref>
