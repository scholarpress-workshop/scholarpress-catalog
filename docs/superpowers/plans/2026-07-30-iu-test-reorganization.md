# IU Template Test Reorganization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move test files from `template/` to `tests/`, delete dead PNGs from template, embed PNGs into chapter body for image rendering coverage, and switch golden baseline from empty `template.typ` to `test-global.typ`.

**Architecture:** `tests/` becomes the canonical test directory. `template/` contains only the entry point (`template.typ`), reusable styles (`styles.typ`), sections (`sections/`), and chapters (`chapters/`). Test files import from `../template/` with adjusted relative paths. `fixtures/compile.sh` golden baseline switches to `test-global.typ`.

**Tech Stack:** Typst 0.15.x, git mv/rm.

## Global Constraints

- `typst compile template.typ` must still work with zero section calls (entry point unchanged).
- All existing `typst compile test-*.typ` commands must work from the new `tests/` location.
- The fixture `golden.pdf` must be a non-trivial multi-page PDF exercising all section functions.
- Test files import sections from `../template/` (one level up, then into template).

---

## Task 1: Move test files and clean up template directory

**Files:**
- Move: `institutions/iu/template/test-global.typ` → `institutions/iu/tests/test-global.typ`
- Move: `institutions/iu/template/test-chapters.typ` → `institutions/iu/tests/test-chapters.typ`
- Move: `institutions/iu/template/fig-2-1.png` → `institutions/iu/tests/fig-2-1.png`
- Move: `institutions/iu/template/fig-3-1.png` → `institutions/iu/tests/fig-3-1.png`
- Move: `institutions/iu/template/fig-4-1.png` → `institutions/iu/tests/fig-4-1.png`
- Move: `institutions/iu/template/fig-4-2.png` → `institutions/iu/tests/fig-4-2.png`

- [ ] **Step 1: Move all 6 files with git mv**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git mv institutions/iu/template/test-global.typ institutions/iu/tests/test-global.typ
git mv institutions/iu/template/test-chapters.typ institutions/iu/tests/test-chapters.typ
git mv institutions/iu/template/fig-2-1.png institutions/iu/tests/fig-2-1.png
git mv institutions/iu/template/fig-3-1.png institutions/iu/tests/fig-3-1.png
git mv institutions/iu/template/fig-4-1.png institutions/iu/tests/fig-4-1.png
git mv institutions/iu/template/fig-4-2.png institutions/iu/tests/fig-4-2.png
```

- [ ] **Step 2: Fix import paths in `test-global.typ`**

All section imports change from `"sections/title-page.typ"` → `"../template/sections/title-page.typ"`, and chapter import from `"chapters/ch01.typ"` → `"../template/chapters/ch01.typ"`. The styles import changes from `"styles.typ"` → `"../template/styles.typ"`.

Replace the import block at the top of `institutions/iu/tests/test-global.typ`:

```typst
#import "../template/styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "../template/sections/title-page.typ": title-page
#import "../template/sections/acceptance.typ": acceptance-page
#import "../template/sections/copyright.typ": copyright-page
#import "../template/sections/dedication.typ": dedication-page
#import "../template/sections/acknowledgements.typ": acknowledgements-page
#import "../template/sections/preface.typ": preface-page
#import "../template/sections/abstract.typ": abstract-page
#import "../template/sections/toc.typ": toc-page
#import "../template/sections/chapters.typ": chapter
#import "../template/sections/references.typ": references-page
#import "../template/sections/cv.typ": curriculum-vitae
```

- [ ] **Step 3: Fix import paths in `test-chapters.typ`**

Replace the import block:

```typst
#import "../template/styles.typ": iu-page-setup, iu-heading-size, iu-body-font
#import "../template/sections/title-page.typ": title-page
#import "../template/sections/acceptance.typ": acceptance-page
#import "../template/sections/chapters.typ": chapter
#import "../template/chapters/ch01.typ": historical-context
```

- [ ] **Step 4: Verify both test files compile from new location**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
typst compile test-global.typ /tmp/test-global-moved.pdf
typst compile test-chapters.typ /tmp/test-chapters-moved.pdf
```

Expected: both PDFs produced, no errors. File sizes should match the originals (~41KB and ~30KB).

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(tests): move test files and PNGs from template/ to tests/"
```

---

## Task 2: Embed PNGs into chapter body for image rendering coverage

**Files:**
- Modify: `institutions/iu/template/chapters/ch01.typ`
- Modify: `institutions/iu/tests/test-chapters.typ` (update import)

- [ ] **Step 1: Add image references to `ch01.typ`**

Add images into the existing chapter body. Insert before the closing `]`:

```typst
  == Visual Evidence

  The following figures illustrate key concepts in glacier science.

  #figure(
    image("../tests/fig-2-1.png", width: 80%),
    caption: [Glacier morphology diagram showing accumulation and ablation zones.],
  )

  #figure(
    image("../tests/fig-3-1.png", width: 80%),
    caption: [Cross-section of a valley glacier illustrating flow dynamics.],
  )

  == Comparative Analysis

  Additional data supports the glacier dynamics model. Figures 4-1 and 4-2
  below show temperature and pressure gradients across multiple field sites.

  #figure(
    image("../tests/fig-4-1.png", width: 80%),
    caption: [Temperature gradients measured at three field sites (2018-2024).],
  ) <fig-temp>

  #figure(
    image("../tests/fig-4-2.png", width: 80%),
    caption: [Pressure distribution across the ablation zone.],
  ) <fig-pressure>

  As shown in @fig-temp and @fig-pressure, the data supports the theoretical
  framework established in Chapter 2.
```

The image paths use `../tests/` because `ch01.typ` lives in `template/chapters/`. From there:
- `..` = `template/`
- `../tests/` = reache `tests/` (sibling of template)

- [ ] **Step 2: Update `test-chapters.typ` import for chapter with images**

The `test-chapters.typ` already imports `historical-context` from `ch01.typ`. The new figure references in `ch01.typ` use paths relative to `ch01.typ`'s location (`../tests/fig-*.png`). When `test-chapters.typ` (in `tests/`) compiles, the `chapter()` function sets `--root` to the template directory. The image paths in `ch01.typ` should resolve correctly relative to the template root.

- [ ] **Step 3: Compile and verify images render**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
typst compile test-chapters.typ /tmp/test-chapters-images.pdf
```

Expected: PDF produced, no errors. File size should be significantly larger than the previous ~30KB (images embedded).

- [ ] **Step 4: Commit**

```bash
git add institutions/iu/template/chapters/ch01.typ
git commit -m "test(template): embed figure PNGs into chapter body for image rendering coverage"
```

---

## Task 3: Switch golden baseline to `test-global.typ`

**Files:**
- Modify: `institutions/iu/tests/fixtures/compile.sh`

- [ ] **Step 1: Update the golden baseline compilation line**

In `institutions/iu/tests/fixtures/compile.sh`, change the last compilation block from:

```bash
echo "=== Generating golden baseline from institution template ==="
typst compile --root "$ROOT/../../template" \
  "$ROOT/../../template/template.typ" \
  "$DIR/golden.pdf"
echo "Golden baseline: $DIR/golden.pdf"
```

To:

```bash
echo "=== Generating golden baseline from test-global.typ ==="
typst compile --root "$ROOT/../../template" \
  "$ROOT/../test-global.typ" \
  "$DIR/golden.pdf"
echo "Golden baseline: $DIR/golden.pdf"
```

- [ ] **Step 2: Regenerate the golden baseline**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: `golden.pdf` now a multi-page PDF (was ~4KB empty, should be ~40KB+ with all sections).

- [ ] **Step 3: Verify the new golden PDF is non-trivial**

```bash
ls -la institutions/iu/tests/fixtures/golden.pdf
```

Expected: file size > 20KB (all sections rendered with sample content and images).

- [ ] **Step 4: Commit**

```bash
git add institutions/iu/tests/fixtures/compile.sh institutions/iu/tests/fixtures/golden.pdf
git commit -m "test(fixtures): switch golden baseline from empty template.typ to test-global.typ"
```

---

## Task 4: Final verification

- [ ] **Step 1: All test files compile from `tests/`**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
typst compile test-global.typ /tmp/test-global-final.pdf
typst compile test-chapters.typ /tmp/test-chapters-final.pdf
```

Expected: both PDFs produced, no errors. `test-chapters-final.pdf` > 50KB (with embedded images).

- [ ] **Step 2: Template entry point still works**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/template
typst compile template.typ /tmp/test-template-final.pdf
```

Expected: PDF produced (empty but valid — unchanged behavior).

- [ ] **Step 3: Fixture suite complete**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog/institutions/iu/tests
bash fixtures/compile.sh
```

Expected: all 11 fixture PDFs + golden baseline regenerate successfully.

- [ ] **Step 4: Template directory is clean**

```bash
ls institutions/iu/template/
```

Expected output:

```
chapters/
sections/
styles.typ
template.typ
```

Only the four essential files/directories. No test files, no stray PNGs.

- [ ] **Step 5: Git status clean**

```bash
cd /home/danriggi/scholarpress-workshop/scholarpress-catalog
git status
```

Expected: clean working tree.
