#!/bin/bash

# ============================================================
# CampWatchMe - alignment_drop_s80_to_40_trial.sh
# Testing -s 40 (was default 80) + -z 400,200 (was 600,200)
# All other flags identical to alignment_repeat_req_flags.sh
# Output: minimap-diff-parameters-trial/drop-s-80-to-40/
# ============================================================

PROJECT=/data1/campwatchme_project/campwatchme-project
REF=/data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
FASTQ=/data/merged_fastq
OUT=/data/minimap-diff-parameters-trial/drop-s-80-to-40

mkdir -p $PROJECT/minimap-diff-parameters-trial/drop-s-80-to-40

# ============================================================
# SAMPLE 11 - Female, Parent 2 (flow cell PBI66128)
# ============================================================
echo "$(date) - Starting alignment: sample-11-female"

podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -L \
    -z 400,200 \
    -s 40 \
    -Y \
    -t 10 \
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
    -z 400,200 \
    -s 40 \
    -Y \
    -t 10 \
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
    -z 400,200 \
    -s 40 \
    -Y \
    -t 10 \
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
echo "BAM files saved in: $PROJECT/minimap-diff-parameters-trial/drop-s-80-to-40"

