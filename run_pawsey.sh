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

if [ -z "${1}" ]; then
    printf "Usage: run_pawsey.sh <pipeline_name>\n"
    exit 1
fi

export PIPELINE="${1}"
printf "PIPELINE: %s\n" "${PIPELINE}"

# get the pipeline version from pipeline_versions.yaml
export PIPELINE_VERSION=$(grep "^${PIPELINE}:" resources/pipeline_versions.yaml | cut -d':' -f2 | tr -d ' ')
if [ -z "${PIPELINE_VERSION}" ]; then
    printf "Pipeline version for %s not found in pipeline_versions.yaml\n" "${PIPELINE}"
    exit 1
fi
printf "PIPELINE_VERSION: %s\n" "${PIPELINE_VERSION}"

printf "TMPDIR: %s\n" "${TMPDIR}"
printf "SLURM_CPUS_ON_NODE: %s\n" "${SLURM_CPUS_ON_NODE}"

if [ -z "${SINGULARITY_CACHEDIR}" ]; then
    export SINGULARITY_CACHEDIR=/software/projects/pawsey1132/tharrop/.singularity
    export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
fi

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

# Pull the containers into the cache before trying to launch the workflow.
# Using release 0.6.2 because dev has a bug with the "MAIN_MAPPING" workflow
# not being defined.
nextflow inspect \
    -concretize "sanger-tol/${PIPELINE}" \
    --input "resources/configs/${PIPELINE}_test.yaml" \
    --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/${PIPELINE}" \
    -profile singularity,pawsey \
    -r "${PIPELINE_VERSION}"

# Note, it's tempting to use the apptainer profile, but the nf-core (and some
# sanger-tol) pipelines have a conditional `workflow.containerEngine ==
# 'singularity'` that prevents using the right URL with apptainer.
nextflow \
    -log "nextflow_logs/nextflow.$(date +"%Y%m%d%H%M%S").${RANDOM}.log" \
    run \
    "sanger-tol/${PIPELINE}" \
    --input "resources/configs/${PIPELINE}_test.yaml" \
    --outdir "s3://pawsey1132.atol.testpostassembly/414129_AusARG/results/${PIPELINE}" \
    -resume \
    -profile singularity,pawsey \
    -r "${PIPELINE_VERSION}"
