# scholarpress-catalog — Core

Open-data registry of institution formatting profiles, Typst templates, and test fixtures. **Zero code dependencies** — pure data repository at the base of the ScholarPress ecosystem DAG.

## Directory structure

```
scholarpress-catalog/
  institutions/
    iu/
      spec.yaml              # 41 checks, document structure, margins, typography
      template/
        template.typ          # Entry point: imports all sections, sets global layout
        styles.typ            # Shared constants (fonts, sizes, spacing, heading formatters)
        sections/
          title-page.typ      # ALL CAPS centered, IU boilerplate clause
          acceptance.typ      # Committee signatures, chair-first ordering
          copyright.typ       # Vertically centered copyright
          dedication.typ
          acknowledgements.typ
          preface.typ
          abstract.typ        # Centered heading + author + title + body
          toc.typ             # Indented dot-leader entries, no-dots CV line
          lot.typ             # List of Tables
          lof.typ             # List of Figures
          lop.typ             # List of Pictures
          loa.typ             # List of Abbreviations
          chapters.typ        # CHAPTER N / TITLE, page numbering reset to arabic
          references.typ      # Single-spaced reference entries
          appendices.typ      # Section divider + per-appendix pages
          cv.typ              # Curriculum Vitae (no page number)
      tests/
        corpus/               # 16 real IU ScholarWorks PDFs (2020-2026)
          YYYY-MM-author.pdf
        fixtures/             # 10 synthetic margin-variant PDFs (known parameters)
          compile.sh          # Regeneration script
          synthetic-body.typ  # Lorem ipsum at 12pt
          synthetic-messy.typ # Mixed elements: headings, figures, tables
          baseline.pdf        # Correct margins: 1.25in sides, 1in top/bottom
          left-narrow.pdf     # L=0.75in (FAIL)
          right-narrow.pdf    # R=0.75in (FAIL)
          left-wide.pdf       # L=R=1.75in (FAIL)
          right-wide.pdf      # symmetric wide
          top-narrow.pdf      # T=0.5in (FAIL)
          top-wide.pdf        # T=2.0in (FAIL)
          bottom-narrow.pdf   # B=0.5in (FAIL)
          asymmetric.pdf      # L=1.5, R=1.0 (FAIL symmetry)
          messy.pdf           # Mixed formatting
      artifacts/              # Reference docs (not used in pipeline)
  journals/                   # Future scope
```

## IU spec.yaml structure

- `institution`: Indiana University
- `source_revision`: September 2025
- `document_structure`: 16 sections in 3 parts (front_matter, body, end_matter)
- `checks`: 41 check definitions across categories:
  - **layout** (2): global_margins, margin_symmetry
  - **typography** (11): font_size, font_family, justification, title_page checks, etc.
  - **structure** (15): section_presence, section_order, page_numbers, headings, TOC, CV, chapters
  - **content** (5): boilerplate_match, committee_order, toc_title_parity, copyright, abstract
  - **human** (8): manual-review flags (footnotes, references spacing, tables/figures, etc.)
- `constants`: degree = "Doctor of Philosophy"

## Key design decisions

- **Fixtures are flat** — no `synthetic/` subdirectory; all fixtures are synthetic
- **Corpus = real dissertations** — unknown ground truth, used for calibration and crash-prevention testing
- **Corpus naming**: `YYYY-MM-author.pdf` for chronological tracking
- **No code** — this is a pure data repo consumed via CATALOG_PATH or rust-embed

## How other modules consume catalog

| Consumer | Mechanism |
|----------|-----------|
| scholarpress-check (dev) | `CATALOG_PATH` env var or `../scholarpress-catalog/` fallback |
| scholarpress-check (prod) | rust-embed in cli binary |
| scholarpress-publish | CATALOG_PATH → Registry loads .yaml + .typ files |
| scholarpress-cli | Passed as `--spec <path>` argument |
| scholarpress-foundry (future) | Subprocess: writes new institution profiles here |

## Adding an institution

1. Create `institutions/<id>/` with spec.yaml + template/ + tests/
2. spec.yaml follows the same schema (checkers reference check IDs by name)
3. Typst template follows the same entrypoint pattern: template.typ + styles.typ + sections/

## Git info
- Remote: `https://github.com/andtheWings/scholarpress-catalog.git`
- 1 commit on `main`
