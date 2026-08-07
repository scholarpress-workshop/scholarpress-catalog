# Indiana University Indianapolis Title-Page Metadata Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the IU catalog profile to `iu-indianapolis` and require explicit degree and department metadata rendered with the exact Indianapolis Graduate School title-page boilerplate.

**Architecture:** Keep the catalog profile as data plus Typst. Make school and university wording fixed in the profile-specific title-page function, require `degree` and `department` as named parameters, and publish canonical string vocabularies without adding compile-time enum validation or a new metadata schema. Update backend tests and documentation that identify the profile by its old path.

**Tech Stack:** Typst, YAML, Bash fixture scripts, Rust tests in `sp-check` and `sp-mcp`, generated `REFERENCE.json`.

## Global Constraints

- Profile ID is `institutions/iu-indianapolis`.
- Institution is `Indiana University Indianapolis`.
- Fixed title-page school is `Indianapolis Graduate School`.
- Fixed title-page university is `Indiana University`.
- `degree` and `department` are required; neither has a default.
- Department strings include their own grammatical prefix and are rendered unchanged.
- `minor`/`concentration` may be preserved as metadata but is not rendered on the title page.
- Do not add compile-time enum validation or a new metadata schema.
- The clause must use explicit Typst `\\` line-break markers, including the standalone marker before the date.

---

## File Map

- `institutions/iu-indianapolis/spec.yaml`: Indianapolis profile identity and title-clause checker.
- `institutions/iu-indianapolis/template/sections/title-page.typ`: Fixed Indianapolis title-page API and exact clause.
- `institutions/iu-indianapolis/template/styles.typ`: Remove obsolete school, campus, degree, and department defaults; publish canonical degree and department arrays alongside shared metadata.
- `institutions/iu-indianapolis/template/template.typ`: Update title-page documentation and imports only as needed after the API change.
- `institutions/iu-indianapolis/tests/test-global.typ`: Explicit degree and department test wiring.
- `institutions/iu-indianapolis/tests/fixtures/compile.sh`: Update paths and any title-page fixture invocation affected by the required parameters.
- `institutions/iu-indianapolis/template/REFERENCE.json`: Regenerated interface documentation.
- `README.md`: Rename the profile and describe the Indianapolis-specific contract.
- `../scholarpress-backend/crates/sp-check/src/spec.rs`: Update the catalog path test.
- `../scholarpress-backend/crates/sp-mcp/src/workspace.rs`: Update test fixtures and expected profile ID/name.
- `../scholarpress-backend/crates/sp-mcp/src/tools.rs`: Update the profile ID example in the tool description.
- `../scholarpress-backend/crates/sp-check/src/calibration.rs`: Update the catalog spec path used by the calibration test.

## Task 1: Rename And Identify The Profile

**Files:**
- Move: `institutions/iu/` -> `institutions/iu-indianapolis/`
- Modify: `institutions/iu-indianapolis/spec.yaml`
- Modify: `README.md`
- Test: `../scholarpress-backend/crates/sp-check/src/spec.rs`
- Test: `../scholarpress-backend/crates/sp-mcp/src/workspace.rs`

**Interfaces:**
- Produces the catalog profile at `institutions/iu-indianapolis`.
- Produces `institution: Indiana University Indianapolis` for registry consumers.

- [ ] **Step 1: Add failing identity assertions**

Update the Rust tests before moving the data so they expect the new profile path and name:

```rust
let path = std::env::var("CATALOG_PATH")
    .map(PathBuf::from)
    .unwrap_or_else(|_| PathBuf::from("../scholarpress-catalog"))
    .join("institutions/iu-indianapolis")
    .join("spec.yaml");
assert_eq!(spec.institution, "Indiana University Indianapolis");
```

In the registry tests, replace `get("iu")` with `get("iu-indianapolis")` and assert the name is `Indiana University Indianapolis`.

- [ ] **Step 2: Run the focused tests and verify failure**

Run from `../scholarpress-backend`:

```bash
rtk cargo test -p sp-check test_load_iu_spec
rtk cargo test -p sp-mcp test_load_institutions
```

Expected: FAIL because the catalog directory and institution value still use the old identity.

- [ ] **Step 3: Move the profile and update its identity**

Run from `scholarpress-catalog`:

```bash
rtk git mv institutions/iu institutions/iu-indianapolis
```

Change the first line of `institutions/iu-indianapolis/spec.yaml` to:

```yaml
institution: Indiana University Indianapolis
```

Update the README profile table, examples, tree, and consumer descriptions from `iu`/`Indiana University` to `iu-indianapolis`/`Indiana University Indianapolis` where they describe this catalog profile.

- [ ] **Step 4: Run the focused tests and verify success**

Run:

```bash
rtk cargo test -p sp-check test_load_iu_spec
rtk cargo test -p sp-mcp test_load_institutions
```

Expected: PASS.

- [ ] **Step 5: Commit the identity change**

```bash
rtk git add institutions/iu-indianapolis README.md
rtk git commit -m "feat: scope IU profile to Indianapolis"
```

## Task 2: Make Title-Page Metadata Explicit

**Files:**
- Modify: `institutions/iu-indianapolis/template/sections/title-page.typ`
- Modify: `institutions/iu-indianapolis/template/styles.typ`
- Modify: `institutions/iu-indianapolis/template/template.typ`
- Modify: `institutions/iu-indianapolis/tests/test-global.typ`

**Interfaces:**
- Consumes: `title`, `author`, `degree`, `department`, `month`, and `year` as named title-page parameters.
- Produces: `title-page(title: none, author: none, degree: none, department: none, month: "", year: "")`, with runtime assertions rejecting omitted `degree` and `department` values.

- [ ] **Step 1: Change the template test to supply explicit metadata**

In `tests/test-global.typ`, remove the local `school-name`, `degree-name`, `department-name`, and `campus-name` bindings and call the title page explicitly:

```typst
#title-page(
  degree: "Doctor of Philosophy",
  department: "in the Program of American Studies",
  month: "May",
  year: "2026",
)
```

- [ ] **Step 2: Run the template test and verify failure**

Run from `institutions/iu-indianapolis/tests`:

```bash
typst compile test-global.typ /tmp/iu-indianapolis-title-page.pdf
```

Expected: FAIL because the current function still accepts and reads the old globals/API.

- [ ] **Step 3: Implement the minimum title-page API**

Replace the metadata imports and parameter block in `sections/title-page.typ` with required degree and department parameters and fixed profile wording:

```typst
#import "../styles.typ": iu-body-size, grad-month, grad-year

#let title-page(
  title: none,
  author: none,
  degree: none,
  department: none,
  month: grad-month,
  year: grad-year,
) = {
  assert(degree != none, message: "title-page requires degree")
  assert(department != none, message: "title-page requires department")
  context {
    let t = if title != none { title } else { document.title }
    let a = if author != none { author } else { document.author.first() }
    [
      #set page(numbering: none)
      #align(center, text(size: iu-body-size, weight: "regular", upper(t)))
      #v(1fr)
      #align(center, text(size: iu-body-size)[#a])
      #v(1fr)
      #align(center)[
        Submitted to the faculty of the Indianapolis Graduate School \
        in partial fulfillment of the requirements \
        for the degree \
        #degree \
        #department \
        Indiana University \
        \
        #month #year
      ]
    ]
  }
}
```

Remove the obsolete title-page defaults from `styles.typ`, and update template comments/examples so they show explicit `degree` and `department` values. Keep `grad-month` and `grad-year` only if the existing template convention still needs them; callers must still be able to override month and year.

- [ ] **Step 4: Run the template test and verify success**

Run:

```bash
typst compile test-global.typ /tmp/iu-indianapolis-title-page.pdf
```

Expected: PASS with no missing-argument or Typst syntax errors.

- [ ] **Step 5: Commit the title-page API change**

```bash
rtk git add institutions/iu-indianapolis/template institutions/iu-indianapolis/tests/test-global.typ
rtk git commit -m "feat: require Indianapolis title metadata"
```

## Task 3: Publish Canonical Metadata And Update The Checker

**Files:**
- Modify: `institutions/iu-indianapolis/spec.yaml`
- Modify: `../scholarpress-backend/crates/sp-mcp/src/tools.rs`
- Modify: `../scholarpress-backend/crates/sp-check/src/calibration.rs`
- Test: `institutions/iu-indianapolis/tests/test-global.typ`

**Interfaces:**
- Produces canonical degree and department vocabularies for extraction/generation guidance.
- Produces the exact seven-line title boilerplate with explicit Typst breaks.

- [ ] **Step 1: Add a representative custom-value test case**

Add a second isolated title-page test entry that supplies:

```typst
#title-page(
  title: "Forensic Evidence",
  author: "Test Author",
  degree: "Master of Science in Forensic Science",
  department: "in the Department of Forensic Science",
  month: "December",
  year: "2026",
)
```

This verifies that the template does not prepend or normalize the department string.

- [ ] **Step 2: Run the focused Typst test and verify success**

```bash
typst compile test-global.typ /tmp/iu-indianapolis-metadata-cases.pdf
```

Expected: PASS.

- [ ] **Step 3: Replace the checker boilerplate**

Set `title_clause_wording.params.template` in `spec.yaml` to the exact clause represented by the existing checker template syntax:

```yaml
template: 'Submitted to the faculty of the Indianapolis Graduate School \\

  in partial fulfillment of the requirements \\

  for the degree \\

  {degree} \\

  {department} \\

  Indiana University \\

  \\

  {month} {year}'
```

  Keep the existing checker ID and page target. Add these exact Typst constants to `template/styles.typ` and document them in the title-page doc comment so `interface_doc` exposes the canonical vocabulary without changing the backend `InstitutionSpec` schema:

  ```typst
  #let canonical-degrees = (
    "Master of Arts",
    "Master of Science",
    "Master of Science in Forensic Science",
    "Doctor of Philosophy",
  )

  #let canonical-departments = (
    "in the School of Dentistry",
    "in the School of Education",
    "in the School of Health and Human Sciences",
    "in the Herron School of Art and Design",
    "in the School of Nursing",
    "in the School of Social Work",
    "in the Lilly Family School of Philanthropy",
    "in the Luddy School of Informatics, Computing, and Engineering",
    "in the Richard M. Fairbanks School of Public Health",
    "in the Department of Anatomy, Cell Biology and Physiology",
    "in the Department of Anthropology",
    "in the Department of Biochemistry and Molecular Biology",
    "in the Department of Biology",
    "in the Department of Biostatistics and Health Data Science",
    "in the Department of Chemistry and Chemical Biology",
    "in the Department of Communication Studies",
    "in the Department of Earth and Environmental Sciences",
    "in the Department of Economics",
    "in the Department of English",
    "in the Department of Forensic Science",
    "in the Department of Geography",
    "in the Department of History",
    "in the Department of Journalism",
    "in the Department of Mathematical Sciences",
    "in the Department of Medical and Molecular Genetics",
    "in the Department of Microbiology and Immunology",
    "in the Department of Museum Studies",
    "in the Department of Pathology",
    "in the Department of Pharmacology and Toxicology",
    "in the Department of Philosophy",
    "in the Department of Physics",
    "in the Department of Psychology",
    "in the Department of Sociology",
    "in the Department of World Languages and Cultures",
    "in the Program of American Studies",
    "in the Program of Medical Neuroscience",
    "in the Program of Musculoskeletal Health Science",
    "in the Program of Translational Cancer Biology",
  )
  ```

  These arrays are guidance only; the title-page function still accepts explicit custom strings.

- [ ] **Step 4: Update profile-facing examples**

Change the MCP tool description example from `institutions/iu` to `institutions/iu-indianapolis`. Change the calibration spec path to `../scholarpress-catalog/institutions/iu-indianapolis/spec.yaml`.

- [ ] **Step 5: Run checker and Rust tests**

Run:

```bash
rtk cargo test -p sp-check
rtk cargo test -p sp-mcp
```

Expected: PASS.

- [ ] **Step 6: Commit checker and vocabulary changes**

```bash
rtk git add institutions/iu-indianapolis/spec.yaml
rtk git commit -m "fix: match Indianapolis title boilerplate"
```

Commit backend changes in the backend repository with its normal commit convention.

## Task 4: Regenerate References And Validate The Profile

**Files:**
- Modify: `institutions/iu-indianapolis/template/REFERENCE.json`
- Modify: `institutions/iu-indianapolis/tests/fixtures/compile.sh`
- Modify: `../scholarpress-backend/crates/sp-mcp/src/workspace.rs`

**Interfaces:**
- Produces generated interface documentation matching the required title-page parameters.
- Produces a clean profile-wide fixture validation run.

- [ ] **Step 1: Update remaining old-path test fixtures**

In `sp-mcp/src/workspace.rs`, change temporary fixture paths, profile IDs, expected profile lists, and expected catalog names from `institutions/iu`/`Indiana University` to `institutions/iu-indianapolis`/`Indiana University Indianapolis`. Keep synthetic fixture names local to the tests; this is a path/identity update, not a behavior change to workspace safety tests.

- [ ] **Step 2: Run the workspace tests and verify failure or stale-reference detection**

```bash
rtk cargo test -p sp-mcp
```

Expected: any remaining old-path assertions are reported; after the updates, the suite passes.

- [ ] **Step 3: Regenerate the interface reference**

Run from `scholarpress-catalog` using the repository’s existing generation workflow:

```bash
typst eval 'query(<ref>).first().value' --in institutions/iu-indianapolis/template/generate-json-ref.typ --root institutions/iu-indianapolis/template > /tmp/typst_output.json
python3 -c "import sys,json; s=json.loads(sys.stdin.read()); data=json.loads(s); print(json.dumps(data, indent=2))" < /tmp/typst_output.json > institutions/iu-indianapolis/template/REFERENCE.json
```

Verify the generated `title-page` signature has required `degree` and `department` parameters and no `school` or `campus` parameters.

- [ ] **Step 4: Recompile fixtures and run catalog validation**

```bash
rtk bash institutions/iu-indianapolis/tests/fixtures/compile.sh
rtk bash institutions/iu-indianapolis/tests/validate_fixtures.sh
```

Expected: all existing fixture assertions pass, with any margin-only expected failures unchanged.

- [ ] **Step 5: Search for stale profile identity**

Run from the workspace root:

```bash
rtk grep 'institutions/iu' scholarpress-catalog scholarpress-backend scholarpress-publish
```

Expected: no active source, test, README, or workflow reference remains for the old profile. Historical design documents may retain old paths as records of prior work and should not be rewritten unless they are executable instructions used by CI.

- [ ] **Step 6: Run final verification**

```bash
rtk git -C scholarpress-catalog diff --check
rtk cargo test --workspace
```

Expected: clean diff check and passing backend workspace tests.

- [ ] **Step 7: Commit generated references and final tests**

```bash
rtk git add institutions/iu-indianapolis/template/REFERENCE.json institutions/iu-indianapolis/tests/fixtures/compile.sh
rtk git commit -m "test: validate IU Indianapolis profile"
```

Commit any backend test/reference updates in the backend repository separately.

## Self-Review

- Profile rename, fixed school/university wording, and README identity are covered by Task 1.
- Required degree/department parameters and exact Typst line breaks are covered by Task 2.
- All supplied canonical degree and department values belong in the profile documentation/metadata during Task 3; no value is selected as a default.
- Optional minor/concentration preservation remains documented but intentionally has no title-page rendering task.
- The exact checker boilerplate and representative American Studies/custom cases are covered by Task 3.
- Generated interface output and old-path consumers are covered by Task 4.
- No placeholders, new dependency, enum schema, or unrelated acceptance/committee changes are included.
