# Indiana University Indianapolis Title-Page Metadata

## Goal

Scope the current IU catalog profile specifically to Indiana University Indianapolis and make title-page metadata explicit enough to prevent campus, degree, and program ambiguity during document generation.

## Profile identity

Rename the profile directory and identifier from `institutions/iu` to `institutions/iu-indianapolis`.

The profile-facing identity is:

- Profile ID: `iu-indianapolis`
- Institution: `Indiana University Indianapolis`
- Fixed title-page school: `Indianapolis Graduate School`
- Fixed title-page university: `Indiana University`

The title-page API must not expose `school` or `campus` parameters. Those values are profile facts and must not be caller-provided. Consumers and tests referencing the old profile path must be updated.

## Title-page API

The title-page function accepts explicit values for all document-specific metadata:

```text
title-page(
  title,
  author,
  degree,
  department,
  month,
  year,
)
```

`degree` and `department` are both required. Neither field has a default. Canonical values guide extraction and generation, but explicit custom values remain supported for programs not present in the catalog.

The title-page clause must render exactly as follows, with the supplied department value rendered unchanged:

```text
Submitted to the faculty of the Indianapolis Graduate School
in partial fulfillment of the requirements
for the degree
{degree}
{department}
Indiana University
{month} {year}
```

Department values include their grammatical prefix, for example `in the Program of American Studies`. The template must not add or remove a prefix.

`minor` or `concentration` remains optional structured workspace metadata for preservation and future use, but is not rendered on this title page.

## Canonical metadata vocabulary

### Degrees

- `Master of Arts`
- `Master of Science`
- `Master of Science in Forensic Science`
- `Doctor of Philosophy`

These values are guidance, not a closed compile-time enum. `Doctor of Philosophy` is not a default and must still be supplied explicitly.

### Departments and programs

- `in the School of Dentistry`
- `in the School of Education`
- `in the School of Health and Human Sciences`
- `in the Herron School of Art and Design`
- `in the School of Nursing`
- `in the School of Social Work`
- `in the Lilly Family School of Philanthropy`
- `in the Luddy School of Informatics, Computing, and Engineering`
- `in the Richard M. Fairbanks School of Public Health`
- `in the Department of Anatomy, Cell Biology and Physiology`
- `in the Department of Anthropology`
- `in the Department of Biochemistry and Molecular Biology`
- `in the Department of Biology`
- `in the Department of Biostatistics and Health Data Science`
- `in the Department of Chemistry and Chemical Biology`
- `in the Department of Communication Studies`
- `in the Department of Earth and Environmental Sciences`
- `in the Department of Economics`
- `in the Department of English`
- `in the Department of Forensic Science`
- `in the Department of Geography`
- `in the Department of History`
- `in the Department of Journalism`
- `in the Department of Mathematical Sciences`
- `in the Department of Medical and Molecular Genetics`
- `in the Department of Microbiology and Immunology`
- `in the Department of Museum Studies`
- `in the Department of Pathology`
- `in the Department of Pharmacology and Toxicology`
- `in the Department of Philosophy`
- `in the Department of Physics`
- `in the Department of Psychology`
- `in the Department of Sociology`
- `in the Department of World Languages and Cultures`
- `in the Program of American Studies`
- `in the Program of Medical Neuroscience`
- `in the Program of Musculoskeletal Health Science`
- `in the Program of Translational Cancer Biology`

There is no default department. In particular, American Studies must be represented as `in the Program of American Studies`, not as the ambiguous free-standing value `American Studies`.

## Validation and documentation

Implementation must update:

- The catalog profile path and profile metadata.
- The Typst title-page function and its generated interface reference.
- The title-page boilerplate check to match the exact seven-line clause.
- Template tests for explicit degree and department values, including the American Studies case and a custom override.
- Tests and consumers that reference `institutions/iu`.
- Catalog README and template documentation to identify the profile as Indianapolis-specific.

The implementation must not add compile-time enum validation or a new metadata schema. Typst parameters remain strings; the required fields and canonical vocabulary provide the ambiguity guard without introducing a second schema system.

## Out of scope

- Bloomington or other Indiana University campus profiles.
- Rendering minor/concentration on the title page.
- Changing acceptance-page wording or committee parsing.
- Inferring degree or department from a source document without explicit confirmation.
