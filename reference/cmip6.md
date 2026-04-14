# Query CMIP6 catalog

Query a local CMIP6 catalog database built from CSV catalog files and
return catalog rows matching the provided filters as a data.table.

## Usage

``` r
cmip6(
  project_id = "CMIP",
  member_id = "r1i1p1f1",
  realm = NULL,
  frequency = NULL,
  table_id = NULL,
  institution_id = NULL,
  source_id = NULL,
  experiment_id = NULL,
  variable_id = NULL,
  grid_label = NULL,
  version = NULL
)
```

## Arguments

- project_id:

  Character filter for the `project_id` column. Defaults to "CMIP".

- member_id:

  Character filter for the `member_id` column. Defaults to "r1i1p1f1".

- realm:

  Character filter for the `realm` column (e.g. "atmos").

- frequency:

  Character filter for the `frequency` column (e.g. "mon").

- table_id:

  Character filter for the `table_id` column (e.g. "Amon").

- institution_id:

  Character filter for the `institution_id` column.

- source_id:

  Character filter for the `source_id` column.

- experiment_id:

  Character filter for the `experiment_id` column.

- variable_id:

  Character filter for the `variable_id` column (e.g. "tas").

- grid_label:

  Character filter for the `grid_label` column.

- version:

  Character filter for the `version` column.

## Value

A `data.table` with rows from the `catalog` table matching the supplied
filters. Only non-NULL arguments are used as filters.

## Details

The function uses a local SQLite database derived from the CSV catalog
files. Database rebuild is moderately slow, but it only needs to be done
once unless the original catalogues are updated.

## Examples

``` r
cmip6(frequency = "mon", variable_id = "tas")
#> Rebuilding catalog database...
#> Warning: cannot create dir '/g/data///runner', reason 'No such file or directory'
#> Error: Could not connect to database:
#> unable to open database file

```
