#!/bin/bash

#SBATCH --job-name=atol_ear
#SBATCH --time=0-12
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=sm.slurm.out
#SBATCH --error=sm.slurm.err

# Dependencies
module load python/3.11.6
module load nextflow/24.04.3
module load singularity/4.1.0-nohost

unset SBATCH_EXPORT

# Application specific commands:
set -eux

source /software/projects/pawsey1132/tharrop/atol-test-postassembly/venv/bin/activate

printf "TMPDIR: %s\n" "${TMPDIR}"
printf "SLURM_CPUS_ON_NODE: %s\n" "${SLURM_CPUS_ON_NODE}"

if [ -z "${SINGULARITY_CACHEDIR}" ]; then
    export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/tharrop/.singularity
    export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
fi

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

rclone mount \
    "pawsey1132://pawsey1132.atol.testassembly/414129_AusARG/results/sanger_tol/414129.hifiasm.20250123/scaffolding/yahs/out.break.yahs" \
    "resources/414129_AusARG" \
    --read-only --daemon
trap 'fusermount -u resources/414129_AusARG' EXIT

# Pull the containers into the cache before trying to launch the workflow.
# Using release 0.6.2 because dev has a bug with the "MAIN_MAPPING" workflow
# not being defined.
nextflow inspect \
    -concretize "sanger-tol/genomenote" \
    --fasta "resources/414129_AusARG/out_scaffolds_final.fa" \
    --assembly "GCA_032191835.1" \
    --biosample_wgs "SAMN37280769" \
    --biosample_hic "SAMN37280769" \
    --input "resources/configs/genomenote_gecko.csv" \
    --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/genomenote" \
    -profile singularity,pawsey \
    -r 2.1.0

# Note, it's tempting to use the apptainer profile, but the nf-core (and some
# sanger-tol) pipelines have a conditional `workflow.containerEngine ==
# 'singularity'` that prevents using the right URL with apptainer.
nextflow \
    -log "nextflow_logs/nextflow.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
    run \
    "sanger-tol/genomenote" \
    --fasta "resources/414129_AusARG/out_scaffolds_final.fa" \
    --assembly "GCA_032191835.1" \
    --biosample_wgs "SAMN37280769" \
    --biosample_hic "SAMN37280769" \
    --input "resources/configs/genomenote_gecko.csv" \
    --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/genomenote" \
    -profile singularity,pawsey \
    -r 2.1.0
