# Nashville Housing Data Cleaning Pipeline

> **Python‑based workflow that ingests messy residential real‑estate datasets, applies robust cleaning & feature‑engineering rules, and outputs analytics‑ready parquet/CSV tables for downstream BI and ML.**

---

## 1  Project Overview

Buying, selling, and valuing homes requires trustworthy data. Public MLS exports, CSVs scraped from listing sites, and municipal open‑data portals often contain duplicates, inconsistent address formats, and missing price/area fields. This repo automates the heavy lifting—turning raw dumps into a tidy, validated dataset you can feed into dashboards or predictive models.

### Key Goals

* **Automate**: One‑command pipeline from raw ➜ clean ➜ enriched.
* **Standardise**: Uniform column names, units (sq ft⇄m²), dates (ISO‑8601), and categorical codes.
* **Validate**: Flag outliers & impossible values (e.g., negative lot sizes), enforce schemas.
* **Document**: Generate data‑quality reports so analysts trust the output.

---

## 2  Data Sources

| Source                 | Format      | Example Fields                                                            |
| ---------------------- | ----------- | ------------------------------------------------------------------------- |
| MLS monthly export     | CSV         | `ListingID`, `ListPrice`, `SqFt`, `Bed`, `Bath`, `PostalCode`, `ListDate` |
| Municipality open data | GeoJSON/CSV | `assessment_value`, `year_built`, `lot_area_m2`, `latitude`, `longitude`  |
| Web‑scraped listings   | JSON        | `address`, `description`, `amenities`, `price_history[]`                  |

---

## 3  Pipeline Architecture

```
Raw Data  ─┐             ┌─▶  /data/clean/{YYYY‑MM‑DD}.parquet  ─┐
           │  clean.py  │                                     │
           ├────────────┤   enrich.py (geo & price adj.) ───▶ BI / ML
           │            │                                     │
`/data/raw`┘            └─▶  /reports/data_quality.html  ─────┘
```

1. **`clean.py`** – handles ingestion, column standardisation, dtype coercion, missing‑value imputation.
2. **`enrich.py`** – computes derived metrics (price / sq ft, age), geocodes postal codes, joins census income tiers.
3. **`validate.py`** – Great Expectations suite; fails build if expectations <95 % pass.
4. **`make report`** – Pandas Profiling summary pushed to `/reports`.

---

## 4  Tech Stack

* **Python 3.11** + [Pandas](https://pandas.pydata.org/), [Polars](https://pola.rs/) (optional speed‑up)
* **Great Expectations** for data QA
* **GeoPy** for geocoding + distance calculations
* **PyProj** + **Shapely** for spatial joins
* **Make**⁠/⁠**Bash** helper commands
* **Docker** (dev‑container) — ensures reproducibility

---

## 5  Folder Structure

```
.
├── data
│   ├── raw/           # untouched source files
│   ├── interim/       # after initial parsing but before full standardisation
│   ├── clean/         # final analytics tables (parquet/csv)
│   └── external/      # lookup tables, geospatial shapes
├── notebooks/         # exploratory analyses & EDA visuals
├── src/
│   ├── utils/         # reusable helpers (parsing, units, logging)
│   ├── clean.py
│   ├── enrich.py
│   └── validate.py
├── reports/
│   └── data_quality.html
├── tests/             # pytest suites covering utils & pipeline
├── Makefile
├── Dockerfile
└── README_Housing_Data_Cleaning.md
```

---

## 6  Quick Start

```bash
# 1. Clone & enter repo
$ git clone https://github.com/<user>/housing-data-cleaning.git && cd housing-data-cleaning

# 2. Build dev container (or use venv)
$ docker compose up -d  # spins up Jupyter & installs deps

# 3. Drop raw files into data/raw/ then run pipeline
$ make clean_data           # executes src/clean.py
$ make enrich_data          # executes src/enrich.py
$ make validate             # runs Great Expectations
$ make report               # builds HTML quality report
```

Outputs land in `/data/clean` with today’s date stamp.

---

## 7  Configuration

Edit `config.yml` to tweak:

* Expected column mappings per source
* Missing‑value strategies (drop | mean | median | model)
* Geo‑API keys and rate limits
* Outlier z‑score thresholds

---

## 8  Testing

```bash
pytest -q   # 95%+ coverage target
```

All merge requests must pass CI (GitHub Actions) running `make lint test validate`.

---

## 9  Contributing

1. Fork ➜ feature branch ➜ PR.
2. Follow **Conventional Commits** for git messages.
3. Run `pre‑commit` hooks locally before pushing.
4. Document any new cleaning rule in `/docs/changelog.md`.

---

## 10  License

MIT © 2025 Gurmukh Sangha.
