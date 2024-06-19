process sourmash_gather {
    tag "${name}"

    cpus 2
    memory 512.MB
    time 1.h
    // time "${((n_reads * 1.2 * 6e-07) as int) + 120}s"

    publishDir 'qc/sourmash', mode: "copy"

    beforeScript "module reset"
    module params.sourmash._module

    input:
    tuple val(name), path(r1), path(r2), val(n_reads)

    output:
    path '*.sourmash.csv'

    stub:
    "touch ${name}.sourmash.csv"

    script:
    scale_factor = 1000000/n_reads
    scale_factor = scale_factor > 1.0 ? 1.0 : scale_factor
    run_str = """
        zcat ${r1} ${r2} \
        | seqtk seq \
            -f ${scale_factor} \
            - \
        | sourmash sketch dna \
            -p k=31,abund,scaled=100 \
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