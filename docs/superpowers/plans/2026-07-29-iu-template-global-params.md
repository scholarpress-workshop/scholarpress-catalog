# IU Template Rewrite: Global Parameters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the IU template so that metadata (author, title, committee, school, degree, department, campus, month, year, defense date) is defined once at the top of `template.typ` using Typst's `#set document(...)` + module-level `#let` variables, and section functions no longer require per-section metadata parameters.

**Architecture:** `#set document(title: [...], author: "Name")` makes metadata contextually available via `context document.title` / `context document.author`. Module-level `#let` variables hold custom metadata (committee, defense_date, institution fields). Section functions wrap their bodies in `context { ... }` to read document metadata; module variables are in scope directly. Original parameters become optional overrides.

**Tech Stack:** Typst 0.15.x. No Rust/backend changes.

**Spec:** `docs/superpowers/specs/2026-07-29-iu-template-global-params.md`

## Global Constraints

- Each section function must REUSE the existing function name (the `#import` lines in `template.typ` don't change).
- Existing callers that pass explicit metadata parameters must continue working identically (parameter defaults route to globals, explicit values override).
- The catalog fixture PDFs (`institutions/iu/tests/fixtures/`) must recompile identically.
- No changes to `styles.typ`.

---

## Task 1: Add document metadata and module-level variables to template.typ

**Files:**
- Modify: `institutions/iu/template/template.typ`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: module-level bindings `committee-members`, `defense-date`, `school-name`, `degree-name`, `department-name`, `campus-name`, `grad-month`, `grad-year` + `#set document(...)` rule. Subsequent tasks read these bindings.

- [ ] **Step 1: Add `#set document(...)` and `#let` variables**

In `institutions/iu/template/template.typ`, after the existing `#set text(font: iu-body-font, size: 12pt)` line and before any section `#import` calls, insert:

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

The file should now read:

```typst
#import "styles.typ": iu-page-setup, iu-margin-top, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/copyright.typ": copyright-page
#import "sections/dedication.typ": dedication-page
#import "sections/acknowledgements.typ": acknowledgements-page
#import "sections/preface.typ": preface-page
#import "sections/abstract.typ": abstract-page
#import "sections/toc.typ": toc-page
#import "sections/lot.typ": list-of-tables
#import "sections/lof.typ": list-of-figures
#import "sections/lop.typ": list-of-pictures
#import "sections/loa.typ": list-of-abbreviations
#import "sections/chapters.typ": chapter
#import "sections/references.typ": references-page
#import "sections/appendices.typ": appendix
#import "sections/cv.typ": curriculum-vitae

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

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

- [ ] **Step 2: Verify template still compiles**

Run: `typst compile institutions/iu/template/template.typ /tmp/test-global.pdf`
Expected: PDF produced, no compilation errors. The PDF may be empty (no section calls in template.typ yet) or identical to the previous build if section calls already exist after the new code.

- [ ] **Step 3: Verify existing fixture compile script still works**

Run: `cd institutions/iu/tests && bash fixtures/compile.sh`
Expected: all fixture PDFs regenerate successfully (the new `#let` variables don't affect the fixture source code).

- [ ] **Step 4: Commit**

```bash
git add institutions/iu/template/template.typ
git commit -m "feat(template): add document metadata and module-level variables"
```

---

## Task 2: Rewrite title-page.typ to use global metadata

**Files:**
- Modify: `institutions/iu/template/sections/title-page.typ`

**Interfaces:**
- Consumes: module-level bindings from Task 1 (`school-name`, `degree-name`, `department-name`, `campus-name`, `grad-month`, `grad-year`), `#set document(title: [...], author: "...")`
- Produces: `title-page(title: none, author: none, school: school-name, degree: degree-name, department: department-name, campus: campus-name, month: grad-month, year: grad-year)` — callers that pass zero args get metadata from globals; callers that pass explicit values get their values.

- [ ] **Step 1: Replace the function body in title-page.typ**

Replace the entire contents of `institutions/iu/template/sections/title-page.typ`:

```typst
#import "../styles.typ": iu-body-size

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
```

- [ ] **Step 2: Verify template still compiles after the change**

Run: `typst compile institutions/iu/template/template.typ /tmp/test-global.pdf`
Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/sections/title-page.typ
git commit -m "feat(template): title-page reads document metadata and module variables"
```

---

## Task 3: Rewrite acceptance.typ to use module-level defaults

**Files:**
- Modify: `institutions/iu/template/sections/acceptance.typ`

**Interfaces:**
- Consumes: module-level bindings from Task 1 (`committee-members`, `defense-date`)
- Produces: `acceptance-page(committee: committee-members, defense_date: defense-date)`

- [ ] **Step 1: Replace the function body in acceptance.typ**

Replace the entire contents of `institutions/iu/template/sections/acceptance.typ`:

```typst
#import "../styles.typ": iu-body-size

#let acceptance-page(
  committee: committee-members,
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
```

This function does NOT need a `context { ... }` wrapper — it only reads module-level variables, which are in scope directly.

- [ ] **Step 2: Verify compilation**

Run: `typst compile institutions/iu/template/template.typ /tmp/test-global.pdf`
Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/sections/acceptance.typ
git commit -m "feat(template): acceptance-page defaults to module-level variables"
```

---

## Task 4: Rewrite abstract.typ to use global metadata

**Files:**
- Modify: `institutions/iu/template/sections/abstract.typ`

**Interfaces:**
- Consumes: `#set document(title: [...], author: "...")`, module-level `committee-members`
- Produces: `abstract-page(heading: "Abstract", author: none, title: none, body: "", committee: committee-members)`

- [ ] **Step 1: Replace the function body in abstract.typ**

Replace the entire contents of `institutions/iu/template/sections/abstract.typ`:

```typst
#import "../styles.typ": iu-heading, iu-body-size, iu-body-font

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
```

- [ ] **Step 2: Verify compilation**

Run: `typst compile institutions/iu/template/template.typ /tmp/test-global.pdf`
Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/sections/abstract.typ
git commit -m "feat(template): abstract-page reads document metadata and module variables"
```

---

## Task 5: Rewrite cv.typ to use document author

**Files:**
- Modify: `institutions/iu/template/sections/cv.typ`

**Interfaces:**
- Consumes: `#set document(author: "...")`
- Produces: `curriculum-vitae(name: none, body: [])` — `name` defaults to `document.author.first()`

- [ ] **Step 1: Replace the function body in cv.typ**

Replace the entire contents of `institutions/iu/template/sections/cv.typ`:

```typst
#let curriculum-vitae(name: none, body: []) = {
  context {
    let n = if name != none { name } else { document.author.first() }
    pagebreak()
    [
      #set page(numbering: none)
      #align(center, text(12pt)[CURRICULUM VITAE])
      #v(12pt)
      #align(center, text(12pt)[#n])
      #v(24pt)
      #body
    ]
  }
}
```

`document.author` is an `array` in Typst — `document.author.first()` gets the first author as content.

- [ ] **Step 2: Verify compilation**

Run: `typst compile institutions/iu/template/template.typ /tmp/test-global.pdf`
Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/sections/cv.typ
git commit -m "feat(template): curriculum-vitae reads name from document.author"
```

---

## Task 6: Create zero-arg test file

**Files:**
- Create: `institutions/iu/template/test-global.typ`

This test file exercises the **zero-arg** calling convention — setting metadata once and calling section functions with no overrides. It proves the global parameters work end-to-end.

- [ ] **Step 1: Write the test file**

Create `institutions/iu/template/test-global.typ`:

```typst
// Zero-arg test: all metadata set via globals, no per-section overrides.
// Compile with: typst compile test-global.typ

#import "styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/copyright.typ": copyright-page
#import "sections/dedication.typ": dedication-page
#import "sections/acknowledgements.typ": acknowledgements-page
#import "sections/preface.typ": preface-page
#import "sections/abstract.typ": abstract-page
#import "sections/toc.typ": toc-page
#import "sections/chapters.typ": chapter
#import "sections/references.typ": references-page
#import "sections/cv.typ": curriculum-vitae

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

#set document(
  title: [A Study of Test-Driven Template Parameters],
  author: "Jane A. Doe",
)

#let committee-members = (
  (name: "Dr. Alice Smith", degree: "Ph.D.", role: "Chair"),
  (name: "Dr. Bob Jones", degree: "Ph.D.", role: ""),
  (name: "Dr. Carol Lee", degree: "Ph.D.", role: ""),
  (name: "Dr. David Brown", degree: "Ed.D.", role: ""),
)
#let defense-date = "May 2026"
#let school-name = "Indiana University"
#let degree-name = "Doctor of Philosophy"
#let department-name = "Computer Science"
#let campus-name = "Bloomington"
#let grad-month = "May"
#let grad-year = "2026"

#title-page()
#acceptance-page()
#copyright-page()
#dedication-page(body: [To my family.])
#acknowledgements-page(body: [I would like to thank...])
#preface-page(body: [This dissertation explores...])
#abstract-page(
  body: [
    The field of test-driven template parameters has long been neglected...
  ],
)
#toc-page()
#chapter(number: "1", title: "Introduction", body: [
  = Background
  This is a test chapter.

  == Subsection
  More content here.
], first: true)
#chapter(number: "2", title: "Methods", body: [
  = Experimental Design
  The experiment was designed to test...
])
#references-page(body: [
  - Smith, A. (2025). *On Template Design*. Journal of Typography, 12(3), 45-67.
])
#curriculum-vitae(body: [
  *Education*

  - Ph.D., Computer Science, Indiana University, 2026
  - M.S., Computer Science, State University, 2022
  - B.S., Mathematics, State University, 2020
])
```

- [ ] **Step 2: Compile the test file**

Run: `cd institutions/iu/template && typst compile test-global.typ /tmp/test-global-out.pdf`
Expected: PDF produced with NO compilation errors. The PDF should contain all sections with the globally-set metadata.

- [ ] **Step 3: Compile to verify the PDF is non-empty**

Run: `ls -la /tmp/test-global-out.pdf`
Expected: file size > 10KB (non-trivial multi-page PDF).

- [ ] **Step 4: Test override behavior — explicit params still work**

Create a temporary second test file `institutions/iu/template/test-override.typ`:

```typst
#import "styles.typ": iu-body-font
#import "sections/title-page.typ": title-page

#set page(margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in))
#set text(font: iu-body-font, size: 12pt)

#set document(title: [Global Title], author: "Global Author")

#let school-name = "Indiana University"
#let degree-name = "Doctor of Philosophy"
#let department-name = ""
#let campus-name = ""
#let grad-month = ""
#let grad-year = ""

// This call should USE the override, not the global
#title-page(title: [Overridden Title], author: "Overridden Author")
```

Run: `cd institutions/iu/template && typst compile test-override.typ /tmp/test-override-out.pdf`
Expected: PDF produced, no errors. (The override is tested by compilation success — if `context { ... }` fails to resolve `document.title` or the override, it would error.)

- [ ] **Step 5: Clean up test files (keep only test-global.typ)**

Run: `rm institutions/iu/template/test-override.typ`
Keep `test-global.typ` — it serves as a living documentation of the zero-arg calling convention.

- [ ] **Step 6: Commit**

```bash
git add institutions/iu/template/test-global.typ
git commit -m "test(template): add zero-arg test file exercising global metadata parameters"
```

---

## Task 7: Verify catalog fixtures still compile identically

The catalog's `institutions/iu/tests/fixtures/compile.sh` generates synthetic PDFs using `#title-page(title: [...], author: [...], ...)` — i.e., the old explicit-parameter style. Since the rewrite keeps parameters as optional overrides, these should compile identically.

- [ ] **Step 1: Regenerate fixture PDFs**

Run: `cd institutions/iu/tests && bash fixtures/compile.sh`
Expected: all 10 fixture PDFs regenerate successfully.

- [ ] **Step 2: Run fixture validation**

Run: `cd institutions/iu/tests && bash validate_fixtures.sh`
Expected: all expected pass/fail assertions hold (identical to pre-rewrite results).

If the validation script fails, diff the old `baseline.pdf` against the newly generated one. Any discrepancy means the rewrite inadvertently changed layout. Abort and investigate which section function's `context { ... }` wrapper introduced a layout delta.

- [ ] **Step 3: Commit (only if validation passes — the existing files shouldn't change)**

If `validate_fixtures.sh` produces the same results as before the rewrite, the fixtures are unchanged. No staged files to commit beyond what's already tracked.

```bash
git status
# Expected: clean working tree (all changes already committed in tasks 1-6)
```

---

## Task 8: Final verification

- [ ] **Step 1: Compile the full template end-to-end**

Run:
```bash
cd institutions/iu/template
typst compile template.typ /tmp/test-final.pdf
```
Expected: PDF produced, zero errors, zero warnings.

- [ ] **Step 2: Verify all test files present and compile**

Run:
```bash
cd institutions/iu/template
typst compile test-global.typ /tmp/test-global-final.pdf
```
Expected: PDF produced, zero errors.

- [ ] **Step 3: Check git log for proper task decomposition**

Run: `git log --oneline -8`
Expected: 7-8 commits, each corresponding to one task. No squashed mega-commit.

