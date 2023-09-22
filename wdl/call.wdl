version 1.0


task call_mappable_bed {
  input {
    File pav_conf
    File pav_asm
    String sample
    File delBed
    File insBed
    File invBed
    File trimBed
    String hap
    String threads
    String mem_gb
  }
  command <<<
    source activate lr-pav
    set -eux
    cp ~{pav_conf} ./config.json
    tar zxvf ~{pav_asm}
    tar zxvf ~{trimBed}
    mv /opt/pav /cromwell_root/
    tree
    snakemake -s pav/Snakefile --cores ~{threads} results/~{sample}/callable/callable_regions_~{hap}_500.bed.gz 
    tar zcvf call_mappable_bed_~{hap}_~{sample}.tgz results/~{sample}/callable/callable_regions_~{hap}_500.bed.gz temp/~{sample}/lg_sv/sv_del_~{hap}.bed.gz temp/~{sample}/lg_sv/sv_del_~{hap}.bed.gz temp/~{sample}/lg_sv/sv_del_~{hap}.bed.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(".snakemake/log/*.snakemake.log")
    File bed = "call_mappable_bed_~{hap}_~{sample}.tgz"
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
