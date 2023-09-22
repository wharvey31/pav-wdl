version 1.0

task tar_asm {
  input {
    File ref
    File hapOne
    File hapTwo
    String sample
    String threads
    String mem_gb
  }
  command <<<
    set -eux
    mkdir -p asm/~{sample}
    cp ~{ref} asm/ref.fa
    samtools faidx asm/ref.fa
    cp ~{hapOne} asm/~{sample}/h1.fa.gz
    cp ~{hapTwo} asm/~{sample}/h2.fa.gz
    tar zcvf asm.tgz asm/
  >>>
  output {
    File asm_tar = "asm.tgz"
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

task write_vcf {
  input {
    File pav_conf
    File pav_asm
    File mappable_h2
    File mappable_h1
    File inv_h1
    File inv_h2
    String threads
    String mem_gb
    String sample
  }
  command <<<
    source activate lr-pav
    set -eux
    cp ~{pav_conf} ./config.json
    tar zxvf ~{mappable_h1}
    tar zxvf ~{mappable_h2}
    tar zxvf ~{inv_h1}
    tar zxvf ~{inv_h2}
    mv /opt/pav /cromwell_root/
    tree
    snakemake -s pav/Snakefile --cores ~{threads} pav_~{sample}.vcf.gz
  >>>
  output {
    Array[File] snakemake_logs = glob(".snakemake/log/*.snakemake.log")
    File vcf = "pav_~{sample}.vcf.gz"
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
