# Stuart WDL (WIP)
Mouse-sized WDL tasks for your workflows. 🐁

Please add your suggestions to the Issues tab and flag them as enhancement.

## arraycheck_exact
For performing a check between an array of truth files and an array of test files. It is assumed that the filenames between the truth and test files match. All md5 mismatches are reported, unless `fastfail == true` in which case the pipeline will fail immediately.

## arraycheck_functequiv
Similar to arraycheck_exact, but upon md5 mismatch, an Rscript is run to check for functional equivalence via `all.equal(testfile, truthfile, tolerance)`. It is assumed that both checked files are RData files. The user may set the tolerance value, which defaults to 1.0e-8.

## metamouse
Checker/Debugger for Stuart tasks. The test files are derived from the [WDL translation](https://github.com/DataBiosphere/analysis_pipeline_WDL) of the [UWGAC TOPMed Pipeline](https://github.com/UW-GAC/analysis_pipeline).
