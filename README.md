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

https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos4/sra-pub-run-30/SRR028/28919/SRR28919959/SRR28919959.1

biosample_hic: SAMN37176091 

https://sra-pub-run-odp.s3.amazonaws.com/sra/SRR25773553/SRR25773553

Config: `resources/genome_note_test.yaml`

