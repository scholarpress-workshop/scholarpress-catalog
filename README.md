# scholarpress-catalog

<img src="catalog_owl.jpg" alt="scholarpress-catalog logo" width="180" align="right">

Open-data registry of formatting profiles, Typst templates, and test fixtures for the [ScholarPress](https://github.com/scholarpress-workshop) ecosystem.

**Zero code dependencies** — pure data repository consumed by [`scholarpress-backend`](https://github.com/scholarpress-workshop/scholarpress-backend) (Rust) for document extraction and validation, and by [`scholarpress-check`](https://github.com/scholarpress-workshop/scholarpress-check) (Python) for legacy PDF checks.

## Status

| Entity type | Profile | Support |
|-------------|---------|---------|
| Institutions — doctoral dissertations | Indiana University | 33 checks, 16-section Typst template |
| Servers — manuscript preprints | Arxiv |
| Journals — manuscript submissions | — |
| Grants — proposal submissions | — |

Profiles follow a uniform schema regardless of entity type. Adding a new profile requires no code changes in downstream tools.

## Quick start

```bash
git clone https://github.com/scholarpress-workshop/scholarpress-catalog
cd scholarpress-catalog/institutions/iu/tests/corpus
./download.sh        # Fetch 16 real dissertation PDFs
```

Set `CATALOG_PATH` for sibling projects:

```bash
export CATALOG_PATH=/path/to/scholarpress-catalog
```

Run fixture validation against the Rust backend:

```bash
cd institutions/iu/tests
bash compile.sh              # Generate synthetic margin-test PDFs
bash validate_fixtures.sh    # Run scholarpress-cli against all fixtures
```

## Repository structure

```
scholarpress-catalog/
  institutions/           # University formatting requirements
    iu/
      spec.yaml           # Formatting rules in YAML (33 checks)
      template/           # 17 Typst files (entrypoint + styles + 15 sections)
      tests/
        corpus/           # Real dissertations (download.sh)
        fixtures/         # 10 synthetic margin-test PDFs + compile.sh
        expected_results.yaml  # Per-fixture pass/fail assertions
        validate_fixtures.sh   # Runs scholarpress-cli against all fixtures
  journals/               # Journal submission guidelines (planned)
  servers/                # Preprint server requirements (planned)
  grants/                 # Grant proposal formatting (planned)
```

## Profile structure

Every profile under a top-level directory follows the same layout:

```
<top-level>/<id>/
  spec.yaml              # Formatting rules in YAML
  template/
    template.typ          # Entry point — imports sections, sets page layout
    styles.typ            # Shared constants (fonts, sizes, spacing)
    sections/             # Per-section Typst files
  tests/
    corpus/
      download.sh         # Fetches real-world PDFs for calibration
    fixtures/             # Synthetic PDFs with known-good and known-bad parameters
    expected_results.yaml # Per-fixture pass/fail assertions
    validate_fixtures.sh  # Runner script
```

### Example: Indiana University dissertation profile

```
institutions/iu/
  spec.yaml              # 33 checks across 9 categories
  template/
    template.typ          # Entry point
    styles.typ            # Shared constants
    sections/
      title-page.typ   | acceptance.typ   | copyright.typ
      dedication.typ   | acknowledgements.typ | preface.typ
      abstract.typ     | toc.typ          | lot.typ
      lof.typ          | lop.typ          | loa.typ
      chapters.typ     | references.typ   | appendices.typ
      cv.typ
  tests/
    corpus/
      download.sh         # Fetches 16 real IU ScholarWorks PDFs (2020-2026)
    fixtures/
      compile.sh          # Regenerates synthetic margin-test PDFs via Typst
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

## How other modules consume catalog

| Consumer | Mechanism |
|----------|-----------|
| `scholarpress-backend` (Rust) | `CATALOG_PATH` env var → `sp-check::spec::load_spec()` loads `spec.yaml` |
| `scholarpress-backend` publish-service | `Registry::load(catalog_path)` at startup → loads all institution specs and templates |
| `scholarpress-cli` | `--spec path/to/spec.yaml` argument |
| `scholarpress-check` (Python) | `CATALOG_PATH` env var or `../scholarpress-catalog/` sibling fallback |
| `scholarpress-publish` (Python) | `CATALOG_PATH` → loads `.yaml` + `.typ` files |

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
  baseline.pdf:
    assert_fails: []
    assert_passes:
      - global_margins
      - margin_symmetry
      - font_size_consistent
      # ...
    ignore_others: true

  left-narrow.pdf:
    assert_fails: ["global_margins"]
    assert_passes: []
    ignore_others: true
```

## Adding a profile

1. Create `<top-level>/<id>/` with `spec.yaml`, `template/`, and `tests/`
2. `spec.yaml` must follow the schema (checkers reference registered checker names)
3. Typst template should follow the entrypoint pattern: `template.typ` + `styles.typ` + `sections/`
4. Add synthetic fixtures with known-good and known-bad PDFs for regression testing
5. Add `expected_results.yaml` with per-fixture assertions
6. Add real-world corpus PDFs via `download.sh` script

## Versioning

This repo follows [SemVer](https://semver.org). Patch bumps for data updates (new checks, template fixes). Minor bumps for new profiles. Major bumps for breaking schema changes to `spec.yaml`.

## License

MIT
