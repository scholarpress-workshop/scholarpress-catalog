# IU Template: Doc Comments Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Typst doc comments to `template.typ` (comprehensive overview), `styles.typ` (metadata block), and `sections/chapters.typ` (heading hierarchy) to eliminate the agent's three most costly pain points from the first end-to-end test: reverse-engineering calling conventions, discovering page-numbering inheritance behavior, and diagnosing `$` in prose.

**Architecture:** Typst `//` comments (visible to agent but invisible to compiler). `template.typ` gets a top-of-file block comment covering calling conventions, global metadata, page numbering, heading hierarchy, `$` escaping, chapter convention, and section ordering. `styles.typ` gets a brief comment above the metadata `#let` block. `chapters.typ` gets a `///` doc comment on the `chapter()` function.

**Tech Stack:** Typst 0.15.x. No Rust/backend changes.

**Spec:** `docs/superpowers/specs/2026-07-30-iu-template-doc-comments.md`

## Global Constraints

- Comments are invisible to the Typst compiler — `typst compile` output must be byte-identical to the pre-comment version.
- No changes to any function logic, parameter lists, or styling rules.
- The `template.typ` comment must appear before any `#import` or `#set` statements so the agent sees it first.
- Golden baseline (`fixtures/golden.pdf`) must regenerate identically.

---

## Task 1: Add top-of-file comment to `template.typ`

**Files:**
- Modify: `institutions/iu/template/template.typ`

- [ ] **Step 1: Insert the comment block before all imports**

Insert the following at the very top of `institutions/iu/template/template.typ` (before the first `#import` line):

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
//   Front matter (i=): set page(numbering: "i") at top level.
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

- [ ] **Step 2: Verify template still compiles identically**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-template-commented.pdf
```

Expected: PDF produced, no errors. Comments are invisible to compiler.

- [ ] **Step 3: Verify golden baseline regenerates identically**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: `golden.pdf` regenerates with the same content as before (comments don't affect output).

- [ ] **Step 4: Commit**

```bash
git add institutions/iu/template/template.typ
git commit -m "docs(template): add top-of-file architecture comment covering calling conventions, page numbering, headings, and $ escaping"
```

---

## Task 2: Add metadata comment to `styles.typ`

**Files:**
- Modify: `institutions/iu/template/styles.typ`

- [ ] **Step 1: Insert comment above the metadata `#let` block**

In `institutions/iu/template/styles.typ`, insert immediately before the `#let committee-members = ()` line:

```typst
// INSTITUTION METADATA — set these once; all section functions read them.
//   committee-members = ((name: "...", degree: "...", role: "..."), ...)
//   defense-date = "May 2026"
//   school-name / degree-name / department-name / campus-name / grad-month / grad-year
//
// number-to-word(n) — converts "1" → "ONE" for spelled-out chapter titles.
```

- [ ] **Step 2: Verify compilation unaffected**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-styles-commented.pdf
```

Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/styles.typ
git commit -m "docs(template): add metadata variable comment to styles.typ"
```

---

## Task 3: Add doc comment to `sections/chapters.typ`

**Files:**
- Modify: `institutions/iu/template/sections/chapters.typ`

- [ ] **Step 1: Insert `///` doc comment above the `chapter()` function**

In `institutions/iu/template/sections/chapters.typ`, insert immediately before `#let chapter(number: "", title: "", body: [], first: false) = {`:

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

- [ ] **Step 2: Verify compilation unaffected**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-chapters-commented.pdf
```

Expected: PDF produced, no errors.

- [ ] **Step 3: Commit**

```bash
git add institutions/iu/template/sections/chapters.typ
git commit -m "docs(template): add heading hierarchy doc comment to chapter() function"
```

---

## Task 4: Final verification

- [ ] **Step 1: All test files compile identically**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
typst compile --root .. test-global.typ /tmp/test-global-docs.pdf
typst compile --root .. test-chapters.typ /tmp/test-chapters-docs.pdf
```

Expected: both PDFs produced, no errors, content identical to pre-comment versions.

- [ ] **Step 2: Regenerate golden baseline — must be identical to pre-comment version**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: `golden.pdf` content identical to the version committed before this plan (comments don't affect PDF output).

- [ ] **Step 3: Agent readability test (manual)**

In a new OpenCode session with the MCP server connected, ask: "Read the IU template and tell me how to call section functions."

Expected: the agent reads `template.typ` and reports back with "all functions use named parameters with `body: [...]` for content." It does NOT reverse-engineer function source or guess at calling conventions.

- [ ] **Step 4: Check git log**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git log --oneline -5
```

Expected: 3 doc commits, each corresponding to one task. Clean working tree.
