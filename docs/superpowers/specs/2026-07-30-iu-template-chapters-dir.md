# IU Template: Per-File Chapter Convention

## Context

The `chapter()` function in `sections/chapters.typ` takes a `body: []` content
block — all chapter content must currently be assembled inline in
`template.typ`. For a real dissertation with 5–10 chapters and hundreds of
pages, this produces an unmanageably large entry file.

During the first end-to-end MCP test, the agent manually concatenated
chapter-length content into a single `template.typ` file. There is no
documented convention for splitting chapters into individual files that
Typst's `#import` can consume.

This design establishes a `chapters/` directory, a per-file naming convention,
and the `#let` export + `#import` pattern. Zero template code changes are
needed — Typst's module system handles per-file modules natively.

## Design

### Directory structure

```
template/
  chapters/              NEW
    .gitkeep              ← ensures the dir is cloned by create_workspace
    ch01.typ              ← #let historical-context = [...]
    ch02.typ              ← #let theoretical-framework = [...]
    ch03.typ              ← #let case-study-west-glacier = [...]
    ...
  sections/
    chapters.typ          UNCHANGED
  template.typ            UNCHANGED (only the body changes: imports + calls)
```

### File content convention

Each chapter file defines exactly one `#let` binding with a descriptive
kebab-case name. The binding's value is a content block containing the
chapter body (Typst markup: headings, paragraphs, figures, equations).

```typst
// template/chapters/ch01.typ
#let historical-context = [
  = Historiography of Glacier Science

  The study of glacial dynamics emerged in the late 19th century...

  == Early Observations

  Agassiz (1840) first proposed...
]
```

The file name is `chNN.typ` (two-digit zero-padded number). The export name
is a descriptive slug of the chapter title. There is no enforced coupling
between the number and the title — the number provides ordering, the export
name provides readability.

### Import and call pattern in `template.typ`

The entry file imports each chapter and maps it to a `chapter()` call:

```typst
// template.typ
#import "chapters/ch01.typ": historical-context
#import "chapters/ch02.typ": theoretical-framework
#import "chapters/ch03.typ": case-study-west-glacier
#import "chapters/ch04.typ": quantitative-analysis
#import "chapters/ch05.typ": synthesis

#set document(title: [My Dissertation], author: "Author Name")
// ... other set rules ...

#title-page()
#acceptance-page()
// ... other front matter ...

#chapter(
  number: "1",
  title: "Historical Context",
  body: historical-context,
  first: true,
)
#chapter(
  number: "2",
  title: "Theoretical Framework",
  body: theoretical-framework,
)
#chapter(
  number: "3",
  title: "Case Study: West Glacier",
  body: case-study-west-glacier,
)
#chapter(
  number: "4",
  title: "Quantitative Analysis",
  body: quantitative-analysis,
)
#chapter(
  number: "5",
  title: "Synthesis and Implications",
  body: synthesis,
)

// ... end matter ...
```

### Workspace bootstrapping

The `chapters/` directory (with `.gitkeep`) must exist in the catalog
template so `create_workspace` copies it into every new workspace. The
existing `copy_dir_recursive` in `sp-mcp` already handles nested
directories, and the `tests/` skip logic (which excludes `tests/corpus/`)
does not match `chapters/`. Zero MCP code changes needed.

### Agent workflow

1. `extract_document` the source → gets chapter titles + body text
2. `create_workspace(name, profile_id)` → workspace has empty `chapters/`
3. For each chapter `i` with title `T` and body `B`:
   - Harness `write chapters/chNN.typ` with content: `#let <slug> = [B]`
4. Harness `edit template.typ` to add `#import` + `#chapter(...)` calls
5. `compile_typst` + `check_pdf` — iterate

The first chapter (`i == 1`) must include `first: true` in its
`#chapter(...)` call, which resets page numbering from Roman numerals
(front matter) to Arabic (body). The agent learns this from the template
docs (catalog#1), not from this design.

## Non-goals

- **Auto-discovery of chapter files.** The agent must explicitly `#import`
  each chapter file in `template.typ`. No `#for` loop over a glob, no
  helper function. Add when the manual import list becomes painful (8+
  chapters).
- **Front matter in `chapters/`.** Sections like abstract,
  acknowledgments, and preface already have their own dedicated files in
  `sections/` with named functions. They stay there.
- **Chapter file self-registration.** Files do not declare their own
  number or title. Numbering and titling live in the `chapter()` call
  site in `template.typ`. This keeps chapter files pure content and
  `template.typ` as the single source of structural truth.
- **Validation that all numbered files exist sequentially.** No checker
  for gaps in chapter numbering. Add when the agent or a human user
  reports mis-numbered chapters.

## Known limitations

**`template.typ` grows linearly with chapter count.** For a 5-chapter
dissertation, 5 import lines + 5 chapter calls is manageable. For 20
chapters, consider adding a `chapters/` iteration helper — deferred per
the auto-discovery non-goal.

**Chapter file naming is manual.** The agent must derive the filename
(`chNN.typ`) from the chapter index and the export name from the chapter
title. No tool derives a slug from a title string. Acceptable for v1;
the agent is capable of kebab-casing a title.

## Verification

- `typst compile template.typ` with chapter content split across files
  produces a PDF structurally identical to the same content assembled
  inline in one file
- `create_workspace` in sp-mcp copies the `chapters/` directory into
  the new workspace (`.gitkeep` ensures the dir exists even if empty)
- Agent end-to-end: extract a DOCX with 3 chapters → create workspace →
  write 3 chapter files → import in template.typ → compile → check →
  all checks pass (or violations are structural, not content-related)
