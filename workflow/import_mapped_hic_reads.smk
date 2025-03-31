#!/usr/bin/env python3


include: "rules/common.smk"


# Combine Hi-C reads as follows: contains the list (-reads) of the HiC reads in
# the indexed CRAM format. There is a suggested method here:
# https://pipelines.tol.sanger.ac.uk/curationpretext/1.0.1/usage
# (Current attempt: don't include the SAM tags. See details at URL.)
rule samtools_view:
    input:
        bam=Path(
            "resources",
            "414129_AusARG",
            "414129_mkdup.bam",
        ),
        ref=Path("resources", "414129_AusARG", "GCA_032191835.1.fasta"),
    output:
        cram=Path("results", "414129_AusARG", "414129_mkdup.cram"),
        index=Path("results", "414129_AusARG", "414129_mkdup.cram.crai"),
        flagstat=Path("results", "414129_AusARG", "414129_mkdup.flagstat"),
    log:
        Path("logs", "samtools_view.log"),
    resources:
        runtime=120,
    shadow:
        "minimal"
    container:
        get_container("samtools")
    shell:
        "samtools view "
        "-@{threads} "
        "{input.bam} "
        "-Ch "
        "-T {input.ref} "
        "-o {output.cram} "
        "2> {log} "
        "&& "
        "samtools index "
        "{output.cram} "
        "2>> {log} "
        "&& "
        "samtools flagstat "
        "{output.cram} "
        "> {output.flagstat} "
        "2>> {log} "
