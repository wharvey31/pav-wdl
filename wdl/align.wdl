version 1.0

task align_cut_tig_overlap_hap {
  input {
    File pav_conf
    File pav_asm
    File asmGz
    String hap
    File bedGz
    String threads
    String mem_gb
    String sample
  }
  command <<<
    source activate lr-pav
    set -eux
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{asmGz}
    tar zxvf ~{bedGz}
    mv /opt/pav /cromwell_root/
    tree
    snakemake -s pav/Snakefile --cores ~{threads} results/~{sample}/align/aligned_tig_~{hap}.bed.gz
    tar czvf align_cut_tig_overlap_~{hap}_~{sample}.tgz results/~{sample}/align/aligned_tig_~{hap}.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(".snakemake/log/*.snakemake.log")
    File trimBed = "align_cut_tig_overlap_~{hap}_~{sample}.tgz"
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
