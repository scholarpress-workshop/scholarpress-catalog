# ScholarPress Catalog

<img src="catalog_owl.jpg" alt="scholarpress-catalog logo" width="180" align="right">

Open-data registry of formatting profiles, Typst templates, test fixtures, and CI tooling for the [ScholarPress](https://github.com/scholarpress-workshop) ecosystem.

**Zero code dependencies** — pure data and Typst consumed by [`scholarpress-backend`](https://github.com/scholarpress-workshop/scholarpress-backend) (Rust) for document extraction, checking, and MCP-based agent workflows.

## Status

| Entity type | Profile | Checks | Template files |
|-------------|---------|--------|-----------------|
| Institutions — doctoral dissertations | Indiana University | 40 | 20 Typst files (3 top-level + 16 sections + 1 chapter) |

Profiles follow a uniform schema regardless of entity type. Adding a new profile requires no code changes in downstream tools.

## Quick start

```bash
git clone https://github.com/scholarpress-workshop/scholarpress-catalog
cd scholarpress-catalog/institutions/iu/tests

# Run fixture validation (requires scholarpress-cli from backend)
bash validate_fixtures.sh
```

Set `CATALOG_PATH` for sibling projects:

```bash
export CATALOG_PATH=/path/to/scholarpress-catalog
```

## Repository structure

```
scholarpress-catalog/
  institutions/           # University formatting requirements
    iu/
      spec.yaml           # Formatting rules in YAML (40 checks)
      template/           # 20 Typst files
        template.typ       # Entry point — imports sections, sets page layout
        styles.typ         # Shared constants (fonts, sizes, spacing)
        generate-json-ref.typ  # Generates REFERENCE.json for interface_doc
        REFERENCE.json      # Pre-rendered function reference (CI-generated)
        sections/          # 16 per-section Typst files
        chapters/          # Per-chapter content files (ch01.typ)
      tests/
        test-global.typ     # Zero-arg entry file test
        test-chapters.typ   # Per-file chapter convention test
        fixtures/           # 11 synthetic PDFs + compile.sh
        expected_results.yaml  # Per-fixture pass/fail assertions
        validate_fixtures.sh   # Runs scholarpress-cli against all fixtures
  scripts/
    check_doc_comments.py   # Validates tidy doc-comment coverage (CI)
```

## Profile structure

Every profile under a top-level directory follows the same layout:

```
<top-level>/<id>/
  spec.yaml              # Formatting rules in YAML
  template/
    template.typ          # Entry point — imports sections, sets page layout
    styles.typ            # Shared constants (fonts, sizes, spacing)
    generate-json-ref.typ  # Tidy parser → REFERENCE.json
    REFERENCE.json         # Pre-rendered function signatures and docs
    sections/             # Per-section Typst files
    chapters/             # Per-chapter content files
  tests/
    test-global.typ       # Entry file test with zero-arg section calls
    test-chapters.typ     # Chapter import convention test
    fixtures/             # Synthetic PDFs with known-good and known-bad parameters
    expected_results.yaml # Per-fixture pass/fail assertions
    validate_fixtures.sh  # Runner script
```

### Example: Indiana University dissertation profile

```
institutions/iu/
  spec.yaml              # 40 checks across 9 categories
  template/
    template.typ          # Entry point with doc comments and imports
    styles.typ            # Shared constants (iu-page-setup, iu-body-font, etc.)
    generate-json-ref.typ  # Uses tidy to parse doc comments → REFERENCE.json
    REFERENCE.json         # Machine-readable function reference (CI-generated)
    sections/
      title-page.typ   | acceptance.typ     | copyright.typ
      dedication.typ   | acknowledgements.typ | preface.typ
      abstract.typ     | toc.typ            | lot.typ
      lof.typ          | lop.typ            | loa.typ
      chapters.typ     | references.typ     | appendices.typ
      cv.typ
    chapters/
      ch01.typ           # Example chapter (per-file convention)
  tests/
    test-global.typ       # Compiles with all sections zero-arg
    test-chapters.typ     # Tests per-file chapter import pattern
    fixtures/
      compile.sh          # Regenerates synthetic margin-test PDFs via Typst
      golden.pdf          # test-global.typ compiled output (reference for CI)
      baseline.pdf        # Correct margins: 1.25in sides, 1in top/bottom
      left-narrow.pdf     # L=0.75in → FAIL global_margins
      right-narrow.pdf    # R=0.75in → FAIL global_margins
      left-wide.pdf       # L=R=1.75in → FAIL global_margins
      right-wide.pdf      # L=R=1.75in → FAIL global_margins
      top-narrow.pdf      # T=0.5in → FAIL global_margins
      bottom-narrow.pdf   # B=0.5in → FAIL global_margins
      top-wide.pdf        # T=2.0in → FAIL global_margins
      asymmetric.pdf      # L=1.5, R=1.0 → FAIL margin_symmetry
      messy.pdf           # Mixed formatting (smoke test only)
    expected_results.yaml
    validate_fixtures.sh
```

## Spec format

`spec.yaml` defines formatting rules for a profile. Checks reference named checkers registered in the `sp-check` crate.

```yaml
institution: Indiana University
source_revision: September 2025

document_structure:
  front_matter:
    - { id: title_page, required: true }
    - { id: acceptance_page, required: true }
  body:
    - { id: chapters, required: true }
  end_matter:
    - { id: references, required: true }
    - { id: curriculum_vitae, required: true }

checks:
  - id: global_margins
    category: layout
    checker: margins
    target: { scope: all_pages }
    params:
      top: 1in
      bottom: 1in
      left: 1.25in
      right: 1.25in

  - id: committee_order
    category: content
    checker: committee_order
    target: { page: acceptance }
    automatable: false
    review_hint: Check committee member order on acceptance page
```

### Checker categories

| Category | Checks | Description |
|----------|--------|-------------|
| `layout` | margins, margin_symmetry | Page margin measurement and symmetry |
| `typography` | font_size, font_weight, font_family, justification, title_page formatting | Font properties and text alignment |
| `structure` | section_presence, section_order, page_numbers, headings, hyperlinks, new chapters | Document organization and navigation |
| `content` | boilerplate_match, committee_order, toc_title_parity, word_count | Required text content matching |
| `footnotes` | font_consistency | Footnote formatting |
| `sections` | references, cv, abstract formatting | Section-specific checks |
| `title_page` | all_caps, clause_centered, clause_spacing | Title page layout |
| `toc_details` | page_numbers_aligned, no_overhang, cv_no_dots | Table of contents formatting |
| `optional_pages` | copyright_page_format | Optional page checks |

## Typst template conventions

The IU template follows a specific import and calling convention documented in `template.typ` header comments:

- **Named parameters:** All section functions use named parameters (e.g., `#title-page(title: "X", author: "Y")`)
- **Zero-arg pattern:** Metadata set via `#set document(title: [...], author: "...")` and `#let` globals. Section functions read globals automatically.
- **Chapter per-file:** Each chapter is one file in `chapters/`. `ch01.typ` exports `#let ch-name = [...]`. Entry file imports and calls `#chapter(number: "1", title: "Title", body: ch-name, first: true)`.
- **Page numbering:** Template sets `"i"` for front matter. `chapter(first: true)` switches to `"1"` for body.
- **`#set` scoping:** Typst `#set` is module-scoped. Section functions capture template.typ's rules, not the entry file's.

The full reference is available in `template/REFERENCE.json` (CI-generated from tidy doc comments) and queryable via the MCP `interface_doc` tool.

## How other modules consume catalog

| Consumer | Mechanism |
|----------|-----------|
| `scholarpress-backend` (Rust) | `CATALOG_PATH` env var → `sp-check::spec::load_spec()` loads `spec.yaml` |
| `sp-mcp` (MCP server) | `create_workspace` copies profile to scratch dir; `interface_doc` reads `REFERENCE.json` |
| `scholarpress-cli` | `--spec path/to/spec.yaml` argument |

## Fixture validation

Each profile includes synthetic PDF fixtures with known margin properties. The `expected_results.yaml` file declares which checks should pass or fail for each fixture, and `validate_fixtures.sh` runs `scholarpress-cli check` against them.

```bash
# Regenerate PDFs from Typst templates
cd institutions/iu/tests
bash fixtures/compile.sh

# Run validation (uses local scholarpress-cli or GHCR Docker image)
bash validate_fixtures.sh
```

The expected results file:

```yaml
fixtures:
  golden.pdf:
    assert_fails: []
    assert_passes:
      - margin_symmetry
      - font_size_consistent
      - copyright_page_format
      # ...
    ignore_others: true

  left-narrow.pdf:
    assert_fails: ["global_margins"]
    assert_passes: []
    ignore_others: true
```

## CI workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `generate-reference.yml` | Push to template files | Compiles `generate-json-ref.typ` with tidy, validates doc-comment coverage, commits `REFERENCE.json` |
| `validate-fixures.yml` | Schedule (6am daily), dispatch | Regenerates synthetic fixtures, runs `validate_fixtures.sh` against backend |

## Adding a profile

1. Create `<top-level>/<id>/` with `spec.yaml`, `template/`, and `tests/`
2. `spec.yaml` must follow the schema (checkers reference registered checker names)
3. Typst template should follow the entrypoint pattern: `template.typ` + `styles.typ` + `sections/`
4. Add `generate-json-ref.typ` for tidy-based function reference generation
5. Add synthetic fixtures with known-good and known-bad PDFs for regression testing
6. Add `expected_results.yaml` with per-fixture assertions
7. Add `test-global.typ` and `test-chapters.typ` entry file tests

## Versioning

This repo follows [SemVer](https://semver.org). Patch bumps for data updates (new checks, template fixes). Minor bumps for new profiles. Major bumps for breaking schema changes to `spec.yaml`.

## License

MIT
