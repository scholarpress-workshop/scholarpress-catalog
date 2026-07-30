# IU Template: Doc Comments for Agent Readability

## Context

During the first end-to-end MCP test, the LLM agent spent its first several
compile cycles reverse-engineering the template's calling conventions,
heading hierarchy, and page-numbering behavior from function source code.
The three explicit friction points were:

1. **Calling conventions** — all section functions use named parameters with
   `body: [...]` for content. The agent used positional syntax and got
   "unclosed delimiter" errors through multiple compile cycles.

2. **Page numbering inheritance** — the top-level `#set page(numbering: "i")`
   silently reverted back matter (references, appendices) to Roman numerals
   after chapters set Arabic. The agent discovered this by manually
   inspecting the PDF output.

3. **`$` in prose** — a single `$17 million` in the CV body broke
   compilation. The agent spent 4 compile cycles binary-searching text
   blocks to isolate the offending character.

This design adds Typst doc comments to the three files an agent reads first:
`template.typ` (comprehensive overview), `styles.typ` (shared metadata),
and `sections/chapters.typ` (heading hierarchy). Remaining section files
are left undocumented — the calling convention is documented once in the
entry point, and the function source speaks for itself.

## Design

### `template.typ` — top-of-file architecture comment

```typst
// IU DISSERTATION TEMPLATE — READ THIS FIRST
//
// CALLING CONVENTION
//   Every section function in this template uses NAMED parameters:
//     #title-page(title: "My Title", author: "Jane Doe")
//   Do NOT use positional calling like `function()[...]` — this fails
//   with "unclosed delimiter".
//
//   Content blocks are passed via `body: [...]` parameters.
//
// GLOBAL METADATA
//   Set once at top: #set document(title: [...], author: "Name")
//   Custom metadata (committee, dates, school, etc.): #let vars in styles.typ
//   Sections read globals automatically — no per-section parameters needed:
//     #title-page()  ← zero-arg call reads document metadata
//
// PAGE NUMBERING
//   Front matter (>i=): set page(numbering: "i") at top level.
//   Chapter body (1=): chapter() sets page(numbering: "1") internally.
//   Back matter: references & appendices MUST set their own numbering
//   or they inherit the top-level "i" (Roman numerals).
//
// HEADING HIERARCHY
//   Chapter title: rendered by chapter(). Agent writes `==` (H2) and
//   `===` (H3) in chapter body. H2: centered+underlined. H3: left-aligned
//   +underlined. Numbered "1.1", "1.1.1". Front matter uses Typst defaults.
//
// $ IN PROSE
//   $ starts math mode. Escape with \$ in body text (e.g., \$17 million).
//
// CHAPTER PER-FILE CONVENTION
//   Each chapter is one file in chapters/: ch01.typ → #let name = [...]
//   template.typ imports: #import "chapters/ch01.typ": ch-name
//   Then calls: #chapter(number: "1", title: "Title", body: ch-name, first: true)
//
// ORDER
//   Required: title-page, acceptance-page, abstract-page, chapters.
//   Optional: copyright, dedication, acknowledgements, preface, toc, lists.
//   End matter: references-page, appendices, curriculum-vitae.
```

### `styles.typ` — shared metadata comment

Insert after the existing constants, above the `#let` metadata block:

```typst
// INSTITUTION METADATA — set these once; all section functions read them.
//   committee-members = ((name: "...", degree: "...", role: "..."), ...)
//   defense-date = "May 2026"
//   school-name / degree-name / department-name / campus-name / grad-month / grad-year
//
// number-to-word(n) — converts "1" → "ONE" for spelled-out chapter titles.
```

### `sections/chapters.typ` — heading hierarchy doc comment

Add above the `#let chapter(...)` function definition:

```typst
/// Renders a dissertation chapter.
///
/// Heading hierarchy (scoped to chapter body, front matter unaffected):
///   == H2 — centered, underlined, numbered "1.1", regular weight
///   === H3 — left-aligned, underlined, numbered "1.1.1", regular weight
///
/// Use `first: true` on the first body chapter to reset page numbering
/// from Roman numerals (front matter) to Arabic (chapter body).
///
/// All parameters are NAMED. Call as:
///   #chapter(number: "1", title: "Introduction", body: intro-content, first: true)
```

## Non-goals

- **Doc comments on individual section files** (title-page.typ,
  acceptance.typ, abstract.typ, cv.typ, etc.). The calling convention is
  documented once in `template.typ`. The function source is self-explanatory
  for an agent that reads Typst code.
- **Doc comments on TOC/list files** (toc.typ, lot.typ, lof.typ, lop.typ,
  loa.typ). These functions have no parameters that need documentation.
- **Doc comments on `chapters/ch01.typ`**. The per-file convention is
  documented in `template.typ`. The example content is self-documenting.
- **A `$` linter or pre-compile checker.** This is a separate MCP tool
  request (backend#2), not a template change.

## Verification

- `typst compile template.typ` — no change in output (comments are invisible
  to the compiler)
- `typst compile test-global.typ` — no change
- `typst compile test-chapters.typ` — no change
- Golden baseline (`fixtures/golden.pdf`) byte-identical to pre-comment
  version (comments don't affect PDF output)
- Agent readability test: in a new OpenCode session, ask the LLM "read the
  IU template and list the calling conventions." The agent should report
  "all functions use named parameters with body: [] for content" without
  reverse-engineering function source.
