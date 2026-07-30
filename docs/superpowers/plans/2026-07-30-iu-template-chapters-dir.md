# Per-File Chapter Convention Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `chapters/` directory to the IU template with `.gitkeep` and an example file demonstrating the `#let` export convention, plus a test file that verifies chapter imports compile.

**Architecture:** The `chapter()` function in `sections/chapters.typ` accepts a `body: []` content block. Chapter files export one `#let` binding each. `template.typ` imports them with `#import` and passes them to `chapter()`. Zero template code changes — Typst's module system handles everything natively.

**Tech Stack:** Typst 0.15.x. No Rust/backend changes.

**Spec:** `docs/superpowers/specs/2026-07-30-iu-template-chapters-dir.md`

## Global Constraints

- The `chapter()` function in `sections/chapters.typ` is unchanged.
- Chapter file names are `chNN.typ` (two-digit zero-padded number).
- Chapter file exports are descriptive kebab-case `#let` bindings.
- Chapter number and title are specified in the `chapter()` call site in `template.typ`, not in the chapter file.
- `.gitkeep` ensures the `chapters/` directory is committed and cloned by `create_workspace`.

---

## Task 1: Create `chapters/` directory with `.gitkeep`

**Files:**
- Create: `institutions/iu/template/chapters/.gitkeep`
- Create: `institutions/iu/template/chapters/.gitkeep` (the directory must exist in git)

**Interfaces:**
- Consumes: nothing
- Produces: an empty `chapters/` directory that git tracks. Subsequent tasks add files inside it.

- [ ] **Step 1: Create the directory and `.gitkeep`**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
mkdir -p chapters
touch chapters/.gitkeep
```

- [ ] **Step 2: Verify the directory is tracked by git**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git add institutions/iu/template/chapters/.gitkeep
git status
```

Expected: `chapters/.gitkeep` is staged as a new file. The `chapters/` directory appears in the index.

- [ ] **Step 3: Verify the template still compiles (empty chapters/ shouldn't break anything)**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-chapters-empty.pdf
```

Expected: PDF produced, no errors. (template.typ currently has no `#import "chapters/"` lines, so the empty dir is ignored.)

- [ ] **Step 4: Commit**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git commit -m "feat(template): add chapters/ directory with .gitkeep"
```

---

## Task 2: Create example chapter file demonstrating the convention

**Files:**
- Create: `institutions/iu/template/chapters/ch01.typ`

**Interfaces:**
- Consumes: the empty `chapters/` directory from Task 1
- Produces: `#let historical-context` binding (a content block). The test file in Task 3 imports and uses it.

- [ ] **Step 1: Create the example chapter file with real-looking placeholder content**

Create `institutions/iu/template/chapters/ch01.typ`:

```typst
// Per-file chapter convention: each file exports one #let binding
// with a descriptive kebab-case name. template.typ imports it via
//   #import "chapters/ch01.typ": historical-context
// and passes it to the chapter() function:
//   #chapter(number: "1", title: "Historical Context", body: historical-context, first: true)

#let historical-context = [
  = Historiography of Glacier Science

  The study of glacial dynamics emerged in the late 19th century when
  naturalists first observed that glaciers were not static formations but
  rivers of ice in slow, perpetual motion. Early accounts by Alpine
  villagers described glaciers advancing and retreating over generations,
  burying pastures and revealing ancient tree stumps. These observations,
  though anecdotal, laid the groundwork for systematic scientific inquiry.

  == Early Observations

  Louis Agassiz, a Swiss naturalist, was among the first to propose that
  glaciers had once covered much of Europe during an "Ice Age" — a radical
  departure from the prevailing belief in a static Earth. In 1840, he
  published _Études sur les glaciers_, documenting striations on bedrock
  and erratic boulders far from their source. His work demonstrated that
  glaciers were powerful geological agents, capable of reshaping
  landscapes over millennia.

  Agassiz's contemporaries were initially skeptical. The notion that ice
  sheets could have extended from the poles to the Mediterranean seemed
  fantastical. Yet by the 1870s, accumulating evidence from Scandinavia,
  the British Isles, and North America had convinced most of the
  scientific community. Geologists began mapping terminal moraines and
  tracing the extent of Pleistocene ice sheets across continents.
]
```

- [ ] **Step 2: Verify the file compiles as a standalone Typst module**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile chapters/ch01.typ /tmp/test-ch01-standalone.pdf
```

Expected: PDF produced, no errors. The output is just the content block rendered with default Typst styling (no template styles applied).

- [ ] **Step 3: Commit**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git add institutions/iu/template/chapters/ch01.typ
git commit -m "feat(template): add example chapter file demonstrating #let export convention"
```

---

## Task 3: Create test file exercising chapter imports

**Files:**
- Create: `institutions/iu/template/test-chapters.typ`

This test file proves the full loop: import chapter from `chapters/`, pass it to `chapter()`, compile to PDF with proper template styling.

- [ ] **Step 1: Create the test file**

Create `institutions/iu/template/test-chapters.typ`:

```typst
// Test: chapter file import convention.
// Compile with: typst compile test-chapters.typ

#import "styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "sections/title-page.typ": title-page
#import "sections/acceptance.typ": acceptance-page
#import "sections/chapters.typ": chapter
#import "chapters/ch01.typ": historical-context

#set page(
  margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in),
  numbering: "i",
)
#set text(font: iu-body-font, size: 12pt)

#set document(title: [Test: Per-File Chapter Convention], author: "Test Author")

#let committee-members = ((name: "Dr. Test Chair", degree: "Ph.D.", role: "Chair"))
#let defense-date = "July 2026"
#let campus-name = "Bloomington"
#let department-name = "Test Department"

#title-page()
#acceptance-page()

// Chapter imported from chapters/ch01.typ
#chapter(
  number: "1",
  title: "Historical Context",
  body: historical-context,
  first: true,
)
```

- [ ] **Step 2: Compile the test file**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile test-chapters.typ /tmp/test-chapters-out.pdf
```

Expected: PDF produced, no errors. Verify the PDF is non-trivial:

```bash
ls -la /tmp/test-chapters-out.pdf
```

Expected: file size > 3KB (at minimum, a multi-page PDF with title page, acceptance page, and chapter content).

- [ ] **Step 3: Verify the chapter content is reachable in the PDF**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile test-chapters.typ - | strings | grep "Agassiz" | head -3
```

Expected: output contains "Agassiz" (proof that the imported chapter content rendered into the PDF).

- [ ] **Step 4: Verify the fixture golden baseline still works**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: all fixture PDFs regenerate successfully, including `golden.pdf` (which compiles `template.typ` — the new `chapters/` dir should not affect it since `template.typ` doesn't import from it yet).

- [ ] **Step 5: Commit**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git add institutions/iu/template/test-chapters.typ
git commit -m "test(template): add test file exercising chapter import convention"
```

---

## Task 4: Final verification

- [ ] **Step 1: All test files compile**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-template.pdf
typst compile test-global.typ /tmp/test-global.pdf
typst compile test-chapters.typ /tmp/test-chapters.pdf
```

Expected: all three PDFs produced, no errors.

- [ ] **Step 2: Check git log for proper task decomposition**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git log --oneline -4
```

Expected: 3-4 commits, each corresponding to one task. No squashed mega-commit.

- [ ] **Step 3: Verify no stray files**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git status
```

Expected: clean working tree.
