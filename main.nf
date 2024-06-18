process sourmash_gather {
    tag "${name}"

    cpus 2
    memory 512.MB
    time "${((n_reads.toInteger() * 1.2 * 6e-07) as int) + 60}s"

    publishDir 'qc/sourmash', mode: "copy"

    module params.sourmash._module

    input:
    tuple val(name), path(r1), path(r2), val(n_reads)

    output:
    path '*.sourmash.csv'

    stub:
    "touch ${name}.sourmash.csv"

    script:
    scale_factor = 0.01
    run_str = """
        zcat ${r1} ${r2} \
        | seqtk seq \
            -f ${scale_factor} \
            - \
        | sourmash sketch dna \
            -p k=31,abund,scaled=1000 \
            -o ${name}.sig \
            - \
        && sourmash gather \
            --threshold-bp 1000 \
            --create-empty-results \
            -o ${name}.sourmash.csv \
            ${name}.sig \
            /opt/resources/apps/sourmash/*.sig
        """
    run_str.stripIndent()
}