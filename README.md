# Stuart WDL (WIP)
Mouse-sized WDL tasks for your workflows. 🐁

Please add your suggestions to the Issues tab and flag them as enhancement.

## task-level

### arraycheck_simple
*Depreciated: Use https://github.com/dockstore/checker-WDL-templates instead*  
For performing a check between an array of truth files and an array of test files. It is assumed that the filenames between the truth and test files match. All md5 mismatches are reported, unless `fastfail == true` in which case the pipeline will fail immediately.

### arraycheck_rdata
*Depreciated: Use https://github.com/dockstore/checker-WDL-templates instead*  
Similar to arraycheck_exact, but upon md5 mismatch, an Rscript is run to check for functional equivalence via `all.equal(testfile, truthfile, tolerance)`. It is assumed that both checked files are RData files. The user may set the tolerance value, which defaults to 1.0e-8.

### big_cheese
Detailed example of how to use to estimate the disk size requirement of a task and/or allow the user to pick a disk size.

### enumouse
Type `enum` exists in CWL, but not WDL. This task very roughly mimics the `enum` type by checking if a string is within an allowed set of values.

### filechecker
*Depreciated: Use https://github.com/dockstore/checker-WDL-templates instead*  
Checks if two files are equivalent, as opposed to arraycheck_* iterating through two arrays. Includes the same Rdata equivalence checker of arraycheck_rdata (disabled by default).

## workflow-level

### dot_product_scatter
Example of how to use the pair variable type along with zip() to do a dot product scatter. This can be used to take a previous scattered task's inputs and outputs, and scatter again in a way that links the inputs with the outputs they generated.

### metamouse
Checker/Debugger for Stuart tasks. The test files are derived from the [WDL translation](https://github.com/DataBiosphere/analysis_pipeline_WDL) of the [UWGAC TOPMed Pipeline](https://github.com/UW-GAC/analysis_pipeline).

### whiskertail
Template for enforcing order in a WDL workspace. This could be useful if you want a workflow to fail early, rather than waste time/money on other steps.
