# IU Template: Sub-Heading Show Rules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the unused `iu-heading`/`iu-chapter-heading` functions with Typst `#show` rules for `==` (H2) and `===` (H3) headings inside chapter bodies, add a `number-to-word` helper for spelled-out chapter titles, and scope all heading styling to chapters only (front matter unaffected).

**Architecture:** `#show heading.where(level: 2/3)` rules live inside the `chapter()` content block, scoping H2 (centered, underlined, numbered "1.1") and H3 (left-aligned, underlined, numbered "1.1.1") to chapter bodies. Chapter title remains manually rendered with spelled-out number via `number-to-word`. `counter(heading).step()` after the title ensures `==` starts at "1.1".

**Tech Stack:** Typst 0.15.x. No Rust/backend changes.

**Spec:** `docs/superpowers/specs/2026-07-30-iu-template-subheadings.md`

## Global Constraints

- Heading show rules are scoped **inside** `sections/chapters.typ` only — front matter and back matter headings use Typst defaults.
- `iu-heading` and `iu-chapter-heading` are removed from `styles.typ`.
- Chapter title uses `number-to-word` for spelling ("CHAPTER ONE", not "CHAPTER 1").
- All heading fonts match the body font (`iu-body-font`) and body size (`iu-body-size`).
- All headings have `weight: "regular"` (not bold) and no italic styling.

---

## Task 1: Add `number-to-word` and remove dead heading functions in `styles.typ`

**Files:**
- Modify: `institutions/iu/template/styles.typ`

**Interfaces:**
- Consumes: nothing
- Produces: `number-to-word(n)` helper available to `sections/chapters.typ`. Removed `iu-heading` and `iu-chapter-heading` (unused, wrong styling).

- [ ] **Step 1: Add `number-to-word` helper and remove `iu-heading` / `iu-chapter-heading`**

In `institutions/iu/template/styles.typ`, replace the `iu-heading` and `iu-chapter-heading` blocks (lines 27-44) with the `number-to-word` function. The file's section should change from:

```typst
#let iu-heading(level, title) = {
  if level == 1 {
    align(center, underline(text(title)))
    v(12pt)
  } else if level == 2 {
    underline(text(title))
    v(6pt)
  } else {
    text(style: "italic", title)
    v(6pt)
  }
}

#let iu-chapter-heading(title) = {
  pagebreak()
  align(center, text(iu-heading-size, upper(title)))
  v(24pt)
}
```

To:

```typst
#let number-to-word(n) = {
  let words = (
    "ONE", "TWO", "THREE", "FOUR", "FIVE",
    "SIX", "SEVEN", "EIGHT", "NINE", "TEN",
    "ELEVEN", "TWELVE", "THIRTEEN", "FOURTEEN", "FIFTEEN",
  )
  let i = int(n)
  if i >= 1 and i <= words.len() {
    words.at(i - 1)
  } else {
    n
  }
}
```

- [ ] **Step 2: Verify `template.typ` and `test-chapters.typ` still compile**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-styles-after.pdf
typst compile test-chapters.typ /tmp/test-chapters-after.pdf
```

Expected: both PDFs produced, no errors. (Removing unused functions shouldn't break anything since nothing imported them.)

- [ ] **Step 3: Verify fixture golden baseline still compiles**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: all fixture PDFs regenerate successfully, including `golden.pdf`.

- [ ] **Step 4: Commit**

```bash
git add institutions/iu/template/styles.typ
git commit -m "feat(template): add number-to-word helper, remove unused iu-heading functions"
```

---

## Task 2: Rewrite `sections/chapters.typ` with show rules

**Files:**
- Modify: `institutions/iu/template/sections/chapters.typ`

**Interfaces:**
- Consumes: `number-to-word` from `styles.typ` (Task 1), `iu-body-size` and `iu-body-font` from `styles.typ`
- Produces: `chapter(number, title, body, first)` with H2/H3 show rules scoped inside the chapter body

- [ ] **Step 1: Replace `sections/chapters.typ`**

Replace the entire contents of `institutions/iu/template/sections/chapters.typ`:

```typst
#import "../styles.typ": iu-body-size, iu-body-font, number-to-word

#let chapter(number: "", title: "", body: [], first: false) = {
  pagebreak()
  [
    #if first {
      counter(page).update(1)
    }
    #set page(numbering: "1")

    // Heading numbering: `==` gets "1.1", `===` gets "1.1.1"
    #set heading(numbering: "1.1")
    counter(heading).update(0)

    // H2 (`==`): centered, title case, underlined, regular weight, single line
    #show heading.where(level: 2): it => {
      align(
        center,
        underline(
          text(
            size: iu-body-size,
            font: iu-body-font,
            weight: "regular",
            it.body,
          ),
        ),
      )
      v(12pt)
    }

    // H3 (`===`): left-aligned, title case, underlined, regular weight, single line
    #show heading.where(level: 3): it => {
      underline(
        text(
          size: iu-body-size,
          font: iu-body-font,
          weight: "regular",
          it.body,
        ),
      )
      v(6pt)
    }

    // Figure/equation show rules (unchanged from original)
    #set figure(gap: 2em)
    #show figure.caption: it => {
      set text(size: iu-body-size)
      it
    }
    #show math.equation: it => {
      if it.has("label") {
        math.equation(
          block: true,
          numbering: "(1)",
          it,
        )
      } else {
        it
      }
    }
    #show ref: it => {
      let el = it.element
      if el != none and el.func() == math.equation {
        let eq = counter(math.equation).at(el.location()).at(0) + 1
        link(
          el.location(),
          [Eq.~#eq],
        )
      } else {
        it
      }
    }

    // Chapter title — spelled-out number, centered, all caps, regular weight
    #align(center)[
      #text(size: iu-body-size, weight: "regular", upper(
        "CHAPTER " + number-to-word(number)
      )) \
      #text(size: iu-body-size, weight: "regular", upper(title))
    ]
    #v(24pt)

    // Advance heading counter so `==` in body gets "1.1" (not just "1")
    counter(heading).step()

    #body
  ]
}
```

- [ ] **Step 2: Verify `template.typ` compiles with the rewrite**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-chapters-rewrite.pdf
```

Expected: PDF produced, no errors. (template.typ has no chapter calls, so the show rules are defined but never triggered — should still compile.)

- [ ] **Step 3: Verify `test-chapters.typ` compiles (H2/H3 styling is applied)**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile test-chapters.typ /tmp/test-chapters-rewrite.pdf
```

Expected: PDF produced, no errors. The `test-chapters.typ` imports `chapter` from `sections/chapters.typ` and calls `#chapter(number: "1", title: "Historical Context", body: historical-context, first: true)`. The chapter body in `chapters/ch01.typ` contains `==` and `===` headings — these should now render with the new H2/H3 styling.

- [ ] **Step 4: Verify fixture golden baseline still compiles**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: all fixture PDFs regenerate successfully. The `golden.pdf` compiles `template.typ` which has no chapter calls — the new chapter function shouldn't affect it.

- [ ] **Step 5: Commit**

```bash
git add institutions/iu/template/sections/chapters.typ
git commit -m "feat(template): add H2/H3 show rules with number-to-word chapter titles"
```

---

## Task 3: Update test file and final verification

**Files:**
- Modify: `institutions/iu/template/test-chapters.typ` (update to use `==`/`===` in chapter body)
- Modify: `institutions/iu/template/chapters/ch01.typ` (add `==`/`===` headings if not already present)

**Interfaces:**
- Consumes: rewritten `chapter()` function from Task 2
- Produces: test file that exercises the H2/H3 styling

- [ ] **Step 1: Update `chapters/ch01.typ` to include `==` and `===` headings**

Append heading examples to the existing content block in `institutions/iu/template/chapters/ch01.typ`. Add inside the content block (after the existing paragraphs, before closing `]`):

```typst
  == Historiography of Glacier Science

  The study of glacial dynamics emerged in the late 19th century...

  === Early Observations

  Louis Agassiz, a Swiss naturalist, was among the first to propose...

  === Institutional Resistance

  Despite accumulating evidence, Agassiz's contemporaries were initially
  skeptical. The notion that ice sheets could have extended from the poles
  to the Mediterranean seemed fantastical.
```

Note: replace the existing `= Heading` / `== Section` markup in `ch01.typ` with the `==` / `===` convention. Currently the file uses `= Historiography of Glacier Science` and `== Early Observations` — change `=` to `==` and `==` to `===` to match the new hierarchy (chapter title is rendered separately, first heading in body is `==`).

- [ ] **Step 2: Compile `test-chapters.typ` and verify H2/H3 rendering**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile test-chapters.typ /tmp/test-headings.pdf
ls -la /tmp/test-headings.pdf
```

Expected: PDF produced, >30KB (multi-page document with styled headings).

- [ ] **Step 3: Verify front matter headings are unstyled (scoping test)**

Create a quick test file `institutions/iu/template/test-heading-scope.typ`:

```typst
#import "styles.typ": iu-page-setup, iu-body-font
#import "sections/chapters.typ": chapter

#set page(margin: (top: 1in, bottom: 1in, left: 1.25in, right: 1.25in))
#set text(font: iu-body-font, size: 12pt)

// Front matter heading — should NOT have chapter styling (no underline, not centered)
= This Is Outside a Chapter

// Chapter body heading — SHOULD have H2 styling (centered, underlined)
#chapter(
  number: "1",
  title: "Test Chapter",
  body: [
    == This Is Inside a Chapter

    Content here.

    === This Is a Subsection

    More content.
  ],
  first: true,
)
```

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile test-heading-scope.typ /tmp/test-heading-scope.pdf
```

Expected: PDF produced, no errors. The "This Is Outside a Chapter" heading renders with Typst defaults (no underline, not centered). The "This Is Inside a Chapter" heading renders with chapter styling (centered + underlined).

Visual verification: open `/tmp/test-heading-scope.pdf` in a PDF viewer. The outside-chapter heading should look different from the inside-chapter headings.

- [ ] **Step 4: Clean up temporary test file and fixture artifacts**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
rm test-heading-scope.typ  # temporary verification file
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git checkout -- institutions/iu/tests/fixtures/  # revert regenerated PDFs
```

- [ ] **Step 5: Commit**

```bash
git add institutions/iu/template/chapters/ch01.typ institutions/iu/template/test-chapters.typ
git commit -m "test(template): update chapter file and test with ==/=== heading hierarchy"
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

- [ ] **Step 2: Fixture golden baseline still regenerates**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: all fixture PDFs regenerate, `golden.pdf` compiles clean.

- [ ] **Step 3: Check git log for proper task decomposition**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git log --oneline -4
```

Expected: 3-4 commits, each corresponding to one task.

- [ ] **Step 4: Verify no stray files**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git status
```

Expected: clean working tree (temporary test files deleted, fixture PDFs restored).
