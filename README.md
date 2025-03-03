# atol-test-postassembly

## Notes

- I don't understand why they run the nested pipelines `sanger_tol_btk.nf` and
  `sanger_tol_cpretext.nf` with `nextflow run`. This causes issues with the
  executor etc. See the files in in `modules/local`.