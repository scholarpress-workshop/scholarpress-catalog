# IU Template: Sub-Heading Conventions and Show Rules

## Context

The IU dissertation formatting guide specifies exact styling for three heading
levels: chapter titles, first-level section headings within chapters, and
second-level subsection headings. The current template has no heading styling
— headings within chapter bodies render with Typst's default appearance.
The `styles.typ` file defines `iu-heading()` (L1=centered+underlined,
L2=underlined, L3=italic) and `iu-chapter-heading()` (pagebreak+uppercase)
but neither function is imported or called by any section file.

During the first end-to-end MCP test, the agent used Typst's default heading
syntax (`=`, `==`, `===`) which compiled successfully but did not match IU
formatting requirements. The agent had no documented guidance on which
heading levels IU expects or how they should be styled.

This design wires up Typst's built-in heading system with `#show` rules
scoped to chapter bodies, removes the unused `iu-heading` and
`iu-chapter-heading` dead code, and adds a `number-to-word` helper for
spelled-out chapter numbers per IU convention.

## Design

### Heading hierarchy

| IU level | Typst | Numbering | Styling |
|----------|-------|-----------|---------|
| Chapter title | Manual in `chapter()` | Spelled-out word (`"ONE"`, `"TWO"`) | Centered, all caps, regular weight, no underline, two lines |
| H2 (section) | `==` (level 2) | "1.1" | Centered, title case, regular weight, underlined, single line |
| H3 (subsection) | `===` (level 3) | "1.1.1" | Left-aligned, title case, regular weight, underlined, single line |

The chapter title is **not** a Typst heading element — it is rendered
manually in the `chapter()` function because that function already handles
page breaks, page numbering reset, figure/equation numbering, and math
show rules. Moving the title into the body would tangle these concerns.

The `counter(heading).step()` call after the chapter title advances the
level-1 counter so that the first `==` in the body gets numbered "1.1"
(rather than just "1" or "0.1").

All show rules are **inside** the `chapter()` content block — scoped to
chapter body only. Front matter sections (abstract, acknowledgments,
preface) and back matter (references, appendices, CV) use Typst's default
heading styling with no interference.

### `chapter()` function rewrite

Replace `sections/chapters.typ`:

```typst
#import "../styles.typ": iu-body-size, iu-body-font

#let chapter(number: "", title: "", body: [], first: false) = {
  pagebreak()
  [
    #if first {
      counter(page).update(1)
    }
    #set page(numbering: "1")

    // Heading numbering and counter reset per chapter
    #set heading(numbering: "1.1")
    counter(heading).update(0)

    // H2 (==): centered, title case, underlined, regular weight
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

    // H3 (===): left-aligned, title case, underlined, regular weight
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

    // Existing figure/equation show rules
    #set figure(gap: 2em)
    #show figure.caption: it => {
      set text(size: iu-body-size)
      it
    }
    #show math.equation: it => {
      if it.has("label") {
        math.equation(block: true, numbering: "(1)", it)
      } else {
        it
      }
    }
    #show ref: it => {
      let el = it.element
      if el != none and el.func() == math.equation {
        let eq = counter(math.equation).at(el.location()).at(0) + 1
        link(el.location(), [Eq.~#eq])
      } else {
        it
      }
    }

    // Chapter title — spelled-out number, centered, all caps
    #align(center)[
      #text(size: iu-body-size, weight: "regular", upper(
        "CHAPTER " + number-to-word(number)
      )) \
      #text(size: iu-body-size, weight: "regular", upper(title))
    ]
    #v(24pt)

    // Advance heading counter so `==` gets "1.1"
    counter(heading).step()

    #body
  ]
}
```

### `number-to-word` helper

Add to `styles.typ` alongside the existing constants:

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

Falls back to the raw number for chapters beyond 15 (the agent would need
to extend the table). Acceptable for v1 — IU dissertations rarely exceed
10 chapters.

### Removals

Remove from `styles.typ`:
- `iu-heading(level, title)` (L28-38) — unused, wrong styling for IU
- `iu-chapter-heading(title)` (L40-44) — unused, superseded by the
  `chapter()` function's inline rendering

### What the agent writes in chapter bodies

```typst
// chapters/ch01.typ
#let historical-context = [
  == Historiography of Glacier Science     // H2 — centered, underlined, numbered "1.1"

  The study of glacial dynamics emerged...

  === Early Observations                   // H3 — left-aligned, underlined, numbered "1.1.1"

  Agassiz (1840) first proposed...

  === Institutional Resistance             // H3 — numbered "1.1.2"

  Despite accumulating evidence...
]
```

The agent writes natural Typst `==` and `===` headings in title case. The
template applies numbering, alignment, underline, and font/weight rules.
No `iu-heading()` call needed — the agent never sees it.

## Non-goals

- **TOC heading style.** The table of contents page (`sections/toc.typ`)
  renders its own heading formatting. TOC entries pick up heading text and
  page numbers via Typst's `outline()` function; heading show rules don't
  affect TOC entry styling.
- **Front matter headings.** Sections like abstract, acknowledgments, and
  preface use their own `heading:` parameters and local styling. They are
  unaffected by the `chapter()`-scoped show rules.
- **Heading numbering in back matter.** References, appendices, and CV use
  their own numbering or none. The show rules are chapter-scoped.

## Known limitations

**`title` case is a convention, not enforced by the template.** The agent
must write headings in title case. The template does not auto-transform
text to title case. This is documented in the heading doc comments
(catalog#1) and verified by future `check_pdf` rules (catalog#4 is the
styling spec, not the checker spec).

**No level-1 heading in Typst's counter for chapter titles.** The chapter
title is manually rendered and doesn't participate in the heading counter
as a level-1 element. Only `==` (level 2) and `===` (level 3) are counted.
This is the correct behavior per IU convention — chapter titles are
numbered by the agent's `number:` parameter, not by Typst's counter.

## Verification

- `typst compile template.typ` with chapter body containing `==` and `===`
  headings → PDF with centered+underlined H2 and left-aligned+underlined H3
- H2 headings numbered "1.1", "1.2" within a chapter
- H3 headings numbered "1.1.1", "1.1.2" under their parent H2
- Front matter PDF sections (abstract, acknowledgments) render with
  Typst's default heading style — no underline or alignment override
- Existing `test-chapters.typ` still compiles after the rewrite
- `check_pdf` against IU spec: heading checks pass (future — catalog#4 is
  the styling spec, checker rules are a separate update)
