version 1.0

task align_cut_tig_overlap {
  input {
    File pav_conf
    File pav_asm
    String hap
    String threads
    String mem_gb
    String sample
  }
  command <<<
    source activate lr-pav
    set -eux
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    mv /opt/pav /cromwell_root/
    tree
    snakemake -s pav/Snakefile --cores ~{threads} results/~{sample}/align/aligned_tig_~{hap}.bed.gz
    tar czvf align_cut_tig_overlap_~{hap}_~{sample}.tgz results/~{sample}/align/aligned_tig_~{hap}.bed.gz temp/~{sample}/align/contigs_~{hap}.fa.gz temp/~{sample}/align/contigs_~{hap}.fa.gz.fai data/ref/n_gap.bed.gz
    tar czvf align_map_~{hap}_~{sample}.tgz temp/~{sample}/align/pre-cut/aligned_tig_~{hap}.sam.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(".snakemake/log/*.snakemake.log")
    File trimBed = "align_cut_tig_overlap_~{hap}_~{sample}.tgz"
    File rawAlign = "align_map_~{hap}_~{sample}.tgz"
  }
  ############################
  runtime {
      cpu:            threads
      memory:         mem_gb + " GiB"
      disks:          "local-disk " + 1000 + " HDD"
      bootDiskSizeGb: 50
      preemptible:    3
      maxRetries:     1
      docker:         "us.gcr.io/broad-dsp-lrma/lr-pav:1.2.1"
  }
}
