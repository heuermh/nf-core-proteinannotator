process EIDER_AMINOACIDHISTOGRAM {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eider:0.1--hdfd78af_0' :
        'biocontainers/eider:0.1--hdfd78af_0' }"

    //def amino_acid_properties = file("${moduleDir}/assets/amino_acid_properties.tsv")
    //def query_template = file("${projectDir}/modules/local/eider/aminoacidhistogram/assets/query_template.sql")

    input:
    tuple val(meta), path(parquet)
    path(amino_acid_properties) from "${moduleDir}/assets/amino_acid_properties.tsv"
    path(query_template) from "${moduleDir}/assets/query_template.sql"

    output:
    tuple val(meta), path("*.histogram.tsv"), emit: histogram
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    eider \
        $args \
        --verbose \
        --skip-history \
        --parameters prefix=${prefix} \
        --parameters amino_acid_properties=${amino_acid_properties} \
        --query-path ${query_template}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eider: \$(eider --version 2>&1 | grep -o 'eider .*' | cut -f2 -d ' ')
    END_VERSIONS
    """
}
