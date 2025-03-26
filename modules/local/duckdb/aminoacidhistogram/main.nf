process DUCKDB_AMINOACIDHISTOGRAM {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"    
    container 'community.wave.seqera.io/library/duckdb-cli:1.0.0--a85d12a2a9de17c9'

    input:
    tuple val(meta), path(parquet)

    output:
    tuple val(meta), path("*.histogram.tsv"), emit: histogram
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def sql = "INSTALL parquet; LOAD parquet; COPY (WITH p AS (SELECT * FROM read_parquet('${parquet}/*.parquet')), s AS (SELECT unnest(string_to_array(sequence, '')) AS aa FROM p), h AS (SELECT unnest(map_entries(histogram(aa))) AS kv FROM s), e AS (SELECT * from read_csv_auto('amino_acid_properties.tsv')) SELECT '${prefix}' AS id, h.kv['value'] AS count, e.* FROM h JOIN e ON h.kv['key'] = e.one_letter_symbol) TO '${prefix}.histogram.tsv' (HEADER, DELIMITER '\t')"
    """
    create_amino_acid_properties.sh
    duckdb :memory: "$sql"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        duckdb: \$( duckdb --version | cut -f 1 -d " " )
    END_VERSIONS
    """
}
