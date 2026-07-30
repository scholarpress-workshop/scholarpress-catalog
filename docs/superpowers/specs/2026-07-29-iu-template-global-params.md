# IU Template Rewrite: Global Parameters via Typst's `document` Set Rule

## Context

The IU dissertation template currently requires callers to pass metadata
(author, title, committee, defense date, school, degree, etc.) as named
parameters to each section function. Author name appears separately in
`title-page`, `acceptance-page`, and `abstract-page` — each as its own local
parameter. Committee members appear in two sections. This creates duplication,
error risk, and a steep learning curve for agents and humans assembling a
dissertation.

Typst provides a built-in metadata system via the `document` element
([ref](https://typst.app/docs/reference/model/document/)). A `#set document(title: [...], author: "Name")` at the top of the
entry file makes metadata contextually available to all content via
`context document.title`, `context document.author`. For custom metadata
not supported by `document` (committee, defense date, institution names),
module-level `#let` variables in `template.typ` serve the same purpose.

During the first end-to-end test of the ScholarPress MCP server, the agent
found these functions by reverse-engineering parameter signatures —
discovering the duplication and the undocumented named-parameter convention
through trial-and-error compilation cycles.

## Design

### Architecture: `document` set rule + module-level `#let` variables

```
template.typ
│
├── #set document(title: ..., author: ...)    ← standard Typst metadata
├── #let committee = (...)                     ← custom metadata
├── #let defense-date = "..."                  ← custom metadata
├── #let school-name = "..."                   ← custom metadata
│   ...
│
├── #title-page()              ← zero-arg; reads from document + lets
├── #acceptance-page()         ← zero-arg; reads committee + defense-date
├── #abstract-page(body: [...])← body only; metadata from document + lets
│   ...
│
└── chapters imported from chapters/ dir (catalog#3, separate design)
```

Each section function wraps its body in `context { ... }` to read
`document.xxx`. Module-level variables are in scope and read directly.
Original parameters are kept as optional overrides: when the caller
passes an explicit value, it wins; when they pass nothing, the default
reads from the global metadata.

### Parameter categories

Three categories of parameters in the rewritten functions:

| Category | Source | Pattern | Examples |
|----------|--------|---------|----------|
| A — Document metadata | `#set document(...)` → `context document.field` | `param: none` → fall back to `document.field` | `title`, `author` |
| B — Custom module-level | `#let var = ...` in `template.typ` | `param: var` (module-level binding as default) | `committee`, `defense_date`, `school`, `degree`, `department`, `campus`, `month`, `year` |
| C — Content blocks | Caller provides per-section | `param: default-literal` (unchanged) | `heading`, `body` |

### Rewritten section functions

**`title-page.typ`** (8 params → all default from doc metadata or module vars):

```typst
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
      ...
    ]
  }
}
```

**`acceptance.typ`** (2 params → default from module vars):

```typst
#let acceptance-page(
  committee: committee-members,
  defense_date: defense-date,
) = {
  [
    #align(center)[Accepted by the graduate faculty...]

    #for (i, member) in committee.enumerate() [
      ...
      #member.name ...
      #if i == 1 and defense_date != "" [
        Defense Date: #defense_date
      ]
    ]
  ]
}
```

Note: `acceptance-page` does NOT need a `context { ... }` wrapper — it
only reads module-level vars, not document metadata. Module vars are in
scope directly.

**`abstract.typ`** (5 params → author/title from doc metadata; committee from module vars; heading/body are content):

```typst
#let abstract-page(
  heading: "Abstract",
  author: none,
  title: none,
  body: "",
  committee: committee-members,
) = {
  context {
    let a = if author != none { author } else { document.author }
    let t = if title != none { title } else { document.title }
    ...
  }
}
```

**`cv.typ`** (2 params → name from doc metadata):

```typst
#let curriculum-vitae(
  name: none,
  body: [],
) = {
  context {
    let n = if name != none { name } else { document.author.first() }
    ...
  }
}
```

`document.author` is an `array` in Typst — `document.author.first()` gets
the first author string.

### Variables defined in `template.typ`

```typst
#set document(
  title: [],
  author: "",
)

#let committee-members = ()
#let defense-date = ""
#let school-name = "Indiana University"
#let degree-name = "Doctor of Philosophy"
#let department-name = ""
#let campus-name = ""
#let grad-month = ""
#let grad-year = ""
```

### Calling from `template.typ`

**Before (explicit params, duplicated across 3 sections):**
```typst
#title-page(title: [...], author: "John", school: "IU", degree: "PhD",
  department: "CS", campus: "Bloomington", month: "May", year: "2026")
#acceptance-page(committee: (...), defense_date: "May 2026")
#abstract-page(heading: "Abstract", author: "John", title: [...],
  body: [...], committee: (...))
#curriculum-vitae(name: "John", body: [...])
```

**After (set metadata once, zero-arg calls):**
```typst
#set document(title: [My Dissertation], author: "John Doe")
#let committee-members = ((name: "Dr. X", degree: "Ph.D.", role: "Chair"), ...)
#let defense-date = "May 2026"
#let department-name = "Computer Science"

#title-page()
#acceptance-page()
#abstract-page(body: [...])
#curriculum-vitae(body: [...])
```

## File-level changes

| File | Change |
|------|--------|
| `institutions/iu/template/template.typ` | Add `#set document(...)` + `#let` variables; simplify section calls |
| `institutions/iu/template/sections/title-page.typ` | Wrap body in `context { ... }`; params default to `none` (doc metadata) or module vars |
| `institutions/iu/template/sections/acceptance.typ` | Params default to module vars; no `context` needed |
| `institutions/iu/template/sections/abstract.typ` | Wrap body in `context { ... }`; `author`/`title` from doc metadata; `committee` from module var |
| `institutions/iu/template/sections/cv.typ` | `name` from `context document.author` |

## Non-goals (ponytail: deliberate deferrals)

- **`chapters/` directory convention (catalog#3)** — separate design; zero template code change needed (Typst `#import` handles it natively)
- **Sub-heading conventions (catalog#4)** — separate design; involves `iu-heading` wiring or docs
- **Template doc comments (catalog#1)** — do AFTER this rewrite; doc comments will describe the new zero-arg pattern
- **Removing per-section parameter support entirely** — parameters remain as overrides; backward compatibility with existing callers that pass explicit values
- **Schema for `#let` variables** — no validation at the Typst level; spec.yaml in the catalog already defines required document structure

## Known limitations

**`document.author` is an array, not a string.** Typst's `author` field stores
multiple authors as an array of strings. Sections that need a single author
name call `document.author.first()` (returns content) or access by index.
Sections that display all authors iterate.

**Module-level variables have no persistence.** If the user edits
`template.typ` and recompiles, the variables reset. This is expected — the
`template.typ` file IS the configuration. No separate config file needed.

**Backward compatibility is maintained but not tested automatically.**
The rewrite keeps all existing parameters as optional with defaults.
Callers that pass explicit values get the same behavior. The catalog's
fixture validation uses `compile.sh` which generates synthetic PDFs from
parameterized template calls — these should still compile identically.

## Verification

- `typst compile template.typ` with zero-arg section calls produces a PDF
  structurally identical to the current explicit-parameter version
- `typst compile template.typ` with explicit overrides (e.g.
  `#title-page(title: [Override])`) produces the expected override behavior
- The existing catalog fixture PDFs (`institutions/iu/tests/fixtures/`)
  recompile identically (diff against `baseline.pdf` or `expected_results.yaml`
  assertions still pass)
