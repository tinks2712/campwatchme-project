#!/bin/bash

# ============================================================
# CampWatchMe - alignment_repeat_req_flags.sh
# All three samples with required flags - VIA PODMAN
# -L: >65535 CIGAR issue for ONT long reads, moves to CG tag
# -z 600,200: default Z score 400 changed to 600
#             stops splitting of ultra-long reads
#             200 = splice Z-drop, not relevant for DNA but required by syntax
# -Y: unaligned bases kept in BAM file (soft clipping)
# Tool: minimap2 v2.30 | samtools v1.21 - VIA PODMAN
# Images: staphb/minimap2:2.30 | staphb/samtools:1.21
# Output: alignments/alignments_req_flags/
# ============================================================

# Define pathways
# PROJECT = real path on server
# REF, FASTQ, OUT = container paths (/data = $PROJECT inside container)
PROJECT=/data1/campwatchme_project/campwatchme-project
REF=/data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
FASTQ=/data/merged_fastq
OUT=/data/alignments/alignments_req_flags

# Create output directory on real server before running- it is already there but just in case
mkdir -p $PROJECT/alignments/alignments_req_flags

# ============================================================
# SAMPLE 11 - Female, Parent 2 (flow cell PBI66128)
# Total bases: 83.4 GB | Reads: 14.33M | Q10: 93.5% | N50: 9826bp
# ============================================================
echo "$(date) - Starting alignment: sample-11-female"

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -L \
    -z 600,200 \
    -Y \
    -t 20 \
    -R '@RG\tID:S11\tSM:sample-11-female\tPL:ONT' \
    $REF \
    $FASTQ/sample-11-female.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-11-female.sorted.bam

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-11-female.sorted.bam

echo "$(date) - DONE: sample-11-female"
echo "================================================"

# ============================================================
# SAMPLE 17 - Male, Parent 1 (flow cell PBK21011)
# Flow cell defect - lower coverage
# ============================================================
echo "$(date) - Starting alignment: sample-17-male"

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -L \
    -z 600,200 \
    -Y \
    -t 20 \
    -R '@RG\tID:S17\tSM:sample-17-male\tPL:ONT' \
    $REF \
    $FASTQ/sample-17-male.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-17-male.sorted.bam

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-17-male.sorted.bam

echo "$(date) - DONE: sample-17-male"
echo "================================================"

# ============================================================
# SAMPLE 23 - Child (flow cell PBK15059)
# Flow cell defect - lower coverage
# ============================================================
echo "$(date) - Starting alignment: sample-23-kid"

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -L \
    -z 600,200 \
    -Y \
    -t 20 \
    -R '@RG\tID:S23\tSM:sample-23-kid\tPL:ONT' \
    $REF \
    $FASTQ/sample-23-kid.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-23-kid.sorted.bam

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-23-kid.sorted.bam

echo "$(date) - DONE: sample-23-kid"
echo "================================================"

echo "$(date) - ALL THREE SAMPLES COMPLETE"
echo "BAM files saved in: $PROJECT/alignments/alignments_req_flags"

