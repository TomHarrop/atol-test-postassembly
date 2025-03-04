# atol-test-postassembly

Trying out various sanger-tol pipelines on our systems

## EAR

Config: `resources/ear_config_test.yaml`

### Notes

- I don't understand why they run the nested pipelines `sanger_tol_btk.nf` and
  `sanger_tol_cpretext.nf` with `nextflow run`. This causes issues with the
  executor etc. See the files in in `modules/local`.

## genomenote


Usage: [](https://pipelines.tol.sanger.ac.uk/genomenote/2.1.0/usage)

The eastern three-lined skink has data on
[BPA](https://data.bioplatforms.com/dataset/?ext_search_by=&q=taxon_id%3A316450)
and a reference genome on
[NCBI](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA980841/).

Assembly: GCA_041722995.2  
biosample_wgs: SAMN41240122  
biosample_hic: SAMN37176091 

Config: `resources/genome_note_test.yaml`

