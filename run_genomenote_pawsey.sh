#!/bin/bash

#SBATCH --job-name=atol_genomenote
#SBATCH --partition=long
#SBATCH --time=4-00
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=sm.slurm.out
#SBATCH --error=sm.slurm.err

# Dependencies
module load python/3.11.6
module load nextflow/24.04.3
module load singularity/4.1.0-nohost
module load rclone/1.63.1

unset SBATCH_EXPORT

# Application specific commands:
set -eux

source /software/projects/pawsey1132/tharrop/atol-test-postassembly/venv/bin/activate

printf "TMPDIR: %s\n" "${TMPDIR}"
printf "SLURM_CPUS_ON_NODE: %s\n" "${SLURM_CPUS_ON_NODE}"

# reference data
rclone mount \
    "pawsey1132://pawsey1132.atol.refdata.v0/busco" \
    "resources/ref/busco" \
    --read-only --daemon

trap 'fusermount -u resources/ref/busco' EXIT

if [ -z "${SINGULARITY_CACHEDIR}" ]; then
    export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/tharrop/.singularity
    export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
fi

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

# Note, the files were manually copied from
# pawsey1132:/pawsey1132.atol.testassembly/414129_AusARG/results/ to
# resources/414129_AusARG get the pipeline running. The import_mapped_hic_reads
# converts the mapped Hi-C reads from
# pawsey1132:/pawsey1132.atol.testassembly/414129_AusARG/results/sanger_tol/414129.hifiasm.20250123/scaffolding/414129_mkdup.bam
# to cram.
# sanger_tol/414129.hifiasm.20250123/scaffolding/yahs/out.break.yahs/out_scaffolds_final.fa
# was manually renamed to GCA_032191835.1 because the genomenote pipeline wants
# an accession number. Because the pipeline uses the Chromosome names from ENA
# (see README), we are now testing with the genome downloaded from ENA (not the
# renamed assembled genome as described above).

# snakemake \
#     --profile profiles/pawsey_v8 \
#     --retries 1 \
#     --cores 12 \
#     --notemp \
#     --local-cores "${SLURM_CPUS_ON_NODE}" \
#     -s workflow/import_mapped_hic_reads.smk

# Pull the containers into the cache before trying to launch the workflow.
# Using release 0.6.2 because dev has a bug with the "MAIN_MAPPING" workflow
# not being defined.
# nextflow inspect \
#     -concretize "sanger-tol/genomenote" \
#     --fasta "resources/414129_AusARG/GCA_032191835.1.fasta" \
#     --assembly "GCA_032191835.1" \
#     --biosample_wgs "SAMN37280769" \
#     --biosample_hic "SAMN37280769" \
#     --input "resources/configs/genomenote_gecko.csv" \
#     --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/genomenote" \
#     -profile singularity,pawsey \
#     -r 2.1.1

    # --lineage_db resources/ref/busco/lineages \
    # --lineage_tax_ids resources/ref/mapping_taxids-busco_dataset_name.eukaryota_odb10.2019-12-16.txt \


# Note, it's tempting to use the apptainer profile, but the nf-core (and some
# sanger-tol) pipelines have a conditional `workflow.containerEngine ==
# 'singularity'` that prevents using the right URL with apptainer.

# nextflow \
#     -log "nextflow_logs/nextflow.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
#     run \
#     "sanger-tol/readmapping" \
#     --fasta "resources/414129_AusARG/GCF_032191835.1_APGP_CSIRO_Hbin_v1_genomic.fna.gz" \
#     --input "resources/configs/readmapping_gecko.csv" \
#     --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/readmapping" \
#     -resume \
#     -profile singularity,pawsey \
#     -r 1.3.4

# for now just copying the results of readmapping into resources

nextflow \
    -log "nextflow_logs/nextflow.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
    run \
    "sanger-tol/genomenote" \
    --fasta "resources/414129_AusARG/GCF_032191835.1_APGP_CSIRO_Hbin_v1_genomic.fna.gz" \
    --assembly "GCF_032191835.1" \
    --biosample_wgs "SAMN37280769" \
    --biosample_hic "SAMN37280769" \
    --note_template https://github.com/sanger-tol/genomenote/raw/refs/tags/2.1.1/assets/genome_note_template.docx \
    --input "resources/configs/genomenote_gecko.csv" \
    --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/genomenote" \
    -resume \
    -profile singularity,pawsey \
    -r 2.1.1

    # --lineage_db resources/ref/busco/lineages \
        # --lineage_tax_ids resources/ref/mapping_taxids-busco_dataset_name.eukaryota_odb10.2019-12-16.txt \
