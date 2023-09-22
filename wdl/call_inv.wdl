version 1.0


task call_inv_batch_merge {
  input {
    String sample
    File pav_conf
    File pav_asm
    String hap
    File trimBed
    String threads
    String mem_gb
  }
  command <<<
    source activate lr-pav
    set -eux
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{tigBed}
    mv /opt/pav /cromwell_root/
    tree
    snakemake -s pav/Snakefile --cores ~{threads} temp/~{sample}/inv_caller/sv_inv_~{hap}.bed.gz
    tar zcvf call_inv_batch_merge_~{hap}_~{sample}.tgz temp/~{sample}/inv_caller/sv_inv_~{hap}.bed.gz temp/~{sample}/cigar/pre_inv/svindel_insdel_~{hap}.bed.gz temp/~{sample}/cigar/pre_inv/snv_snv_~{hap}.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(".snakemake/log/*.snakemake.log")
    File bed = "call_inv_batch_merge_~{hap}_~{sample}.tgz "
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
