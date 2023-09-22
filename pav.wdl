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
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call align.align_cut_tig_overlap as align_cut_tig_overlap_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call call_inv.call_inv_batch_merge as call_inv_batch_merge_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      trimBed = align_cut_tig_overlap_h1.trimBed,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call call_inv.call_inv_batch_merge as call_inv_batch_merge_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      trimBed = align_cut_tig_overlap_h2.trimBed,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call call_pav.call_mappable_bed as call_mappable_bed_h1 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h1",
      trimBed = align_cut_tig_overlap_h1.trimBed,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call call_pav.call_mappable_bed as call_mappable_bed_h2 {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      hap = "h2",
      trimBed = align_cut_tig_overlap_h2.trimBed,
      threads = "48",
      mem_gb = "128",
      sample = sample
  }
  call setup.write_vcf {
    input:
      pav_conf = config,
      pav_asm = tar_asm.asm_tar,
      mappable_h2 = call_mappable_bed_h2.bed
      mappable_h1 = call_mappable_bed_h1.bed
      inv_h1 = call_inv_batch_merge_h1.bed
      inv_h2 = call_inv_batch_merge_h2.bed
      threads = "48",
      mem_gb = "128",
      sample = sample,
      contigInfo = data_ref_contig_table.contigInfo,
      finalBedOut = call_final_bed.bed
  }
  output {
    File vcf = write_vcf.vcf
  }
}
