# fates_next_api rebase into ctsm1.0.dev093 

This folder contains supporting materials for validation of the rebase effort to bring fates_next_api in line with the ctsm master branch.

## Regression tests summary

### A. fates_main_api (`sci.1.40.2`) versus fates_next_api (`sci.1.40.2`)

- Purpose: What changes are due to the rebase
- How: Running `fates` test suite with fates_next_api as the baseline
    - DIFFs had to be conducted manually due to run start time differences
- Output: `/glade/u/home/glemieux/scratch/ctsm-tests/tests_fates_main_api-fatessuite-2`
- Conclusion:

### B. fates_main_api (`sci.1.40.2`) versus ctsm1.0.dev093(`sci.1.30.0`)

- Purpose: Determine if any non-fates tests are not B4B
- How: Running `aux_clm` suite with fates_main_api against ctsm baseline
    - Fates specific tests DIFFs had to be manually conducted due to differences in output type (i.e. int vs. real)
- Output: `/glade/u/home/glemieux/scratch/ctsm-tests/tests_fates_main_api-aux_clm`
- Conclusion:
    - All non-fates tests are B4B

### C. fates_next_api (`sci.1.40.2`) versus fates_next_api (`sci.1.30.0`)

- Purpose: what changed in the fates output between 1.30.0 and 1.40.2?
    - Run to compare the fates specific output of test suite [B.](###B)
- How: Manually DIFF the fates_next_api baselines against each other
- Location: `/glade/u/home/glemieux/scratch/fma-diffs/fates-sci.1.40.2_api.13.0.1-fates-sci-1.30.0_api.8.0.0`
- Conclusion:

## Long-term tests (100 year)

### Single site test: BCI

- Case location: lobata workstation
    - Baseline: `/home/glemieux/scratch/clmed-cases/fna-rebase-2.Cabcd5937-F3248e633.2020-08-05`
    - Test: `/home/glemieux/scratch/clmed-cases/fna-rebase-2.Cd6ef097c-F3248e633.2020-08-05`

### Gridded run test: f10 grid

- Case location: cheyenne
    - Baseline: `/glade/u/home/glemieux/scratch/clmed-tests/fates_next_api-100_year.fates.cheyenne.Cabcd5937-F6bfea0f8`
    - Test: `/glade/u/home/glemieux/scratch/clmed-tests/fates_main_api-100_year.fates.cheyenne.Cc56788f3-F6bfea0f8`
