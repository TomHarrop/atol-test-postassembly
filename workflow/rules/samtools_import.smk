# Combine Hi-C reads as follows: contains the list (-reads) of the HiC reads in
# the indexed CRAM format. There is a suggested method here:
# https://pipelines.tol.sanger.ac.uk/curationpretext/1.0.1/usage
# (Current attempt: don't include the SAM tags. See details at URL.)
rule samtools_import:
    input:
        r1=Path(
            "resources",
            "reads",
            "350769_AusARG_BRF_HCN7WDRXY_S5_L001_R1_001.fastq.gz",
        ),
        r2=Path(
            "resources",
            "reads",
            "350769_AusARG_BRF_HCN7WDRXY_S5_L001_R2_001.fastq.gz",
        ),
    output:
        cram=to_storage(Path(dataset_id, "results", "reads", "hic", "hic.cram")),
        index=to_storage(Path(dataset_id, "results", "reads", "hic", "hic.cram.crai")),
    log:
        Path("logs", "samtools_import.log"),
    resources:
        runtime=120,
    container:
        get_container("samtools")
    shell:
        "samtools import "
        "-@{threads} "
        "{input.r1} "
        "{input.r2} "
        "-o {output.cram} "
        "2> {log} "
        "&& "
        "samtools index "
        "{output.cram} "
        "2>> {log} "
