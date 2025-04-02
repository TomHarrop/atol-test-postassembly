# atol-test-postassembly

Trying out various sanger-tol pipelines on our systems

## ASCC

## TreeVal


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


Bynoe's Gecko (that we assembled)

No idea if the seq material was really from this BioSample

Assembly: GCA_032191835.1	
RefSeq: GCF_032191835.1
biosample_wgs: SAMN37280769 
biosample_hic: SAMN37280769 

```csv
sample,datatype,datafile
414129_AusARG,hic,resources/414129_AusARG/reads/hic/hic.cram
414129_AusARG,pacbio,resources/414129_AusARG/reads/hifi/ccs_reads.fasta.gz
```

### Notes

- The pipeline pulls chromosome names from the registered asssembly. So this
  will ONLY work after the assembly has been posted on INSDC.
- What reads does the pipeline expect in the HiC cram file?
  - In the first attempt I used unmapped reads but many of the
    scaffolding-related variables were empty. I think it expects HiC reads
    mapped to the genome assembly.
  - The genomeassembly pipeline outputs these as bam but genomenote expects
  cram, and the first thing it does is convert it back to bam. Makes me think
  these aren't the reads it's looking for. But what then?
- The mapped reads need to be mapped to the GenBank assembly with
  sanger-tol/readmapping.
- **Use the GenBank, NOT RefSeq assembly**. [Genome assembly APGP_CSIRO_Hbin_v1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_032191835.1/)
  - The RefSeq assembly is `GCF_032191835.1`
  - The GenBank assembly is `GCA_032191835.1`
  - GenomeNote doesn't seem to accept the RefSeq accession, and it has
    different chromosome names to the GenBank assembly. So to get everything to
    work, you have to run readmapping with the GenBank assembly, and then
    GenomeNote with the GenBank assembly.


`414129_AusARG_T2_sorted.pairs`:

```
A00548:503:HKWJJDMXY:1:1101:10104:36589	0	ptg000002l01	22000966	8	0	ptg000002l01	21992299	16	60	60
```

`GCA_032191835.1_chrom.list`:

```
CM063325.1	285831653
CM063326.1	205803199
```
