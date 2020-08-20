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
    - Run to compare the fates specific output of test suite [B.](#b-fates_main_api-sci1402-versus-ctsm10dev093sci1300)
- How: Manually DIFF the fates_next_api baselines against each other
- Location: `/glade/u/home/glemieux/scratch/fma-diffs/fates-sci.1.40.2_api.13.0.1-fates-sci-1.30.0_api.8.0.0`
- Conclusion: 
    - Comparing test DIFFs between C. and B.
        - The main limitation in comparing the test sets is there is little overlap in the gridsets used for both suites.
            - `1x1_brazil` and `f45_f45_mg37` are the only overlaps
        - Note that all `aux_clm` fates test use the testmod 'FatesColdDef'.  This furhter limits the set of tests to compare.
        - The `aux_clm` fates tests are either SMS or ERS tests
        - As a result of the above, the closest match between the `fates` suite and `aux_clm` suite tests is: `ERS_D_Mmpi-serial_Ld5.1x1_brazil.I2000Clm50FatesGs.cheyenne_intel.clm-FatesColdDef`
              - Note that the atmospheric data set is different between the two however.
        - Comparison of the RMS values can be found here, although results are not entirely supportive of a specific hypothesis: https://docs.google.com/spreadsheets/d/1RlVrx0y7MW4jIZpSl3FB-wnHJiCTbYNZQ_5jn8jk9Kc/edit?usp=sharing 
        

## Long-term tests (100 year)

### Single site test: BCI

- Case location: lobata workstation
    - fates_next_api baselines:
        - Baseline 1 (sci.1.36.0_api.11.2.0): `/home/glemieux/scratch/clmed-cases/fna-rebase.Ce33b4658-F7c065e21.2020-07-27`
        - Baseline 2 (sci.1.40.1_api.13.0.1): `/home/glemieux/scratch/clmed-cases/fna-rebase-2.Cabcd5937-F3248e633.2020-08-05`
    - fates_main_api tests: 
        - Test 1 (sci.1.36.0_api.11.2.0): `/home/glemieux/scratch/clmed-cases/fna-rebase.C024b43a8-F7c065e21.2020-07-27`
        - Test 2 (sci.1.40.1_api.13.0.1): `/home/glemieux/scratch/clmed-cases/fna-rebase-2.Cd6ef097c-F3248e633.2020-08-05`

### Gridded run test: `f10_f10_mg37` grid

The gridded runs were conducted with fates tag `sci.1.40.3_api.13.0.1`

- Case location: cheyenne
    - Baseline: `/glade/u/home/glemieux/scratch/clmed-tests/fates_next_api-100_year.fates.cheyenne.Cabcd5937-F6bfea0f8`
    - Test: `/glade/u/home/glemieux/scratch/clmed-tests/fates_main_api-100_year.fates.cheyenne.Cc56788f3-F6bfea0f8`
