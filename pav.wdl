version 1.0

import "wdl/setup_wrapup.wdl" as setup
import "wdl/align.wdl" as align
import "wdl/call.wdl" as call_pav
import "wdl/call_inv.wdl" as call_inv
import "wdl/call_lg.wdl" as call_lg


workflow pav {
  input {
    File ref
    File refFai

    File hapOne
    File hapTwo

    String sample

    File config
  }

  call setup.tar_asm {
    input:
      ref = ref,
      hapOne = hapOne,
      hapTwo = hapTwo,
      threads = "1",
      mem_gb = "2",
      sample = sample
  }
  call align.align_cut_tig_overlap as align_cut_tig_overlap_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      bedGz = align_get_read_bed_h1.bedGz,
      asmGz = align_get_tig_fa_h1.asmGz,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call align.align_cut_tig_overlap as align_cut_tig_overlap_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      bedGz = align_get_read_bed_h2.bedGz,
      asmGz = align_get_tig_fa_h2.asmGz,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call call_inv.call_inv_batch_mergeas call_inv_batch_merge_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      invBed = call_inv_batch_h1.bed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_inv.call_inv_batch_merge as call_inv_batch_merge_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      invBed = call_inv_batch_h2.bed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_del_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      svtype = "del",
      inbed = call_lg_discover_h1.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_ins_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      svtype = "ins",
      inbed = call_lg_discover_h1.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_inv_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      svtype = "inv",
      inbed = call_lg_discover_h1.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_del_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      svtype = "del",
      inbed = call_lg_discover_h2.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_ins_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      svtype = "ins",
      inbed = call_lg_discover_h2.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call call_lg.call_merge_lg as call_merge_lg_inv_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      svtype = "inv",
      inbed = call_lg_discover_h2.allBed,
      threads = "1",
      mem_gb = "8",
      sample = sample
  }
  call setup.write_vcf {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      threads = "1",
      mem_gb = "16",
      sample = sample,
      contigInfo = data_ref_contig_table.contigInfo,
      finalBedOut = call_final_bed.bed
  }
  output {
    File vcf = write_vcf.vcf
  }
}
