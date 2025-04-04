// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { INTERPROSCAN_SETUP   } from '../../../modules/local/interproscan/setup/main'
include { INTERPROSCAN_RUN     } from '../../../modules/local/interproscan/run/main'

workflow INTERPROSCAN {

    take:
    // TODO nf-core: edit input (take) channels
    ch_multifasta // channel: [ val(meta), fasta ]

    main:

    ch_versions = Channel.empty()

    if !(params.skip_interproscan_database_setup) {
        INTERPROSCAN_SETUP (
            [file(params.interproscan_database, checkIfExists: true), params.interproscan_database_version]
        )
        ch_versions = ch_versions.mix(INTERPROSCAN_SETUP.out.versions.first())
    }

    INTERPROSCAN_RUN ( SAMTOOLS_SORT.out.bam )
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

