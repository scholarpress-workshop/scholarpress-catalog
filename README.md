# scholarpress-catalog

<img src="catalog_owl.jpg" alt="scholarpress-catalog logo" width="180" align="right">

Open-data registry of formatting profiles, Typst templates, and test fixtures for the [ScholarPress](https://github.com/scholarpress-workshop) ecosystem.

**Zero code dependencies** — pure data repository consumed by [`scholarpress-check`](https://github.com/scholarpress-workshop/scholarpress-check) for PDF validation and [`scholarpress-publish`](https://github.com/scholarpress-workshop/scholarpress-publish) for automated document generation.

## Status

| Entity type | Profile | Support |
|-------------|---------|---------|
| Institutions — doctoral dissertations | Indiana University | ✅ 41 checks, 16-section Typst template |
| Servers — manuscript preprints | Arxiv | 🔜 Planned |
| Journals — manuscript submissions | — | 🔜 Planned |
| Grants — proposal submissions | — | 🔜 Planned |

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

## Repository structure

```
scholarpress-catalog/
  institutions/           # University formatting requirements
    iu/
      spec.yaml           # 327 lines, 41 checks
      template/           # 17 Typst files (entrypoint + styles + 15 sections)
      tests/
        corpus/           # Real dissertations (download.sh)
        fixtures/         # 10 synthetic margin-test PDFs + compile.sh
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
```

### Example: Indiana University dissertation profile

```
institutions/iu/
  spec.yaml              # 327 lines, 41 checks
  template/
    template.typ          # Entry point — imports sections, sets page layout
    styles.typ            # Shared constants (fonts, sizes, spacing)
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
      compile.sh          # Regenerates synthetic margin-test PDFs
      baseline.pdf        # Correct margins: 1.25in sides, 1in top/bottom
      left-narrow.pdf     # L=0.75in (FAIL)
      right-narrow.pdf    # R=0.75in (FAIL)
      left-wide.pdf       # L=R=1.75in (FAIL)
      right-wide.pdf      # Symmetric wide
      top-narrow.pdf      # T=0.5in (FAIL)
      top-wide.pdf        # T=2.0in (FAIL)
      bottom-narrow.pdf   # B=0.5in (FAIL)
      asymmetric.pdf      # L=1.5, R=1.0 (FAIL symmetry)
      messy.pdf           # Mixed formatting
```

## Spec format

`spec.yaml` defines formatting rules for a profile:

```yaml
institution: Indiana University
source_revision: September 2025

document_structure:
  front_matter:
    - { id: title_page,   required: true }
    - { id: acceptance_page, required: true }
    # ...

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
    checker: review
    target: { page: acceptance }
    automatable: false
    review_hint: Check committee order on acceptance page
```

See [`scholarpress-check`](https://github.com/scholarpress-workshop/scholarpress-check) for the full checker catalog (33 automated + 8 human review across layout, typography, structure, and content categories).

## How other modules consume catalog

| Consumer | Mechanism |
|----------|-----------|
| `scholarpress-check` | `CATALOG_PATH` env var or `../scholarpress-catalog/` sibling fallback |
| `scholarpress-publish` | `CATALOG_PATH` → Registry loads `.yaml` + `.typ` files |
| `scholarpress-foundry` (future) | Writes new profiles here as subprocess output |

## Adding a profile

1. Create `<top-level>/<id>/` with `spec.yaml`, `template/`, and `tests/`
2. `spec.yaml` must follow the same schema (checkers reference check IDs by name)
3. Typst template should follow the entrypoint pattern: `template.typ` + `styles.typ` + `sections/`
4. Add synthetic fixtures with known-good and known-bad PDFs for regression testing
5. Add real-world corpus PDFs via `download.sh` script

## Versioning

This repo follows [SemVer](https://semver.org). Patch/minor bumps for data updates (new checks, template fixes). Major bumps for breaking schema changes to `spec.yaml`.

## License

MIT
