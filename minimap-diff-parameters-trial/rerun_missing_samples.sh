#!/bin/bash

# ============================================================
# Rerun S17 and S23 for all four parameter trials
# S11 already completed successfully in all four
# ============================================================

PROJECT=/data1/campwatchme_project/campwatchme-project
REF=/data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
FASTQ=/data/merged_fastq

# ============================================================
# TRIAL 1 — drop-z-score (-z 400,200 only)
# ============================================================
OUT=/data/minimap-diff-parameters-trial/drop-z-score
echo "$(date) - TRIAL 1: drop-z-score"

for SAMPLE in sample-17-male sample-23-kid; do
    echo "$(date) - Starting: $SAMPLE"
    podman run --rm \
      -v $PROJECT:/data:z \
      staphb/minimap2:2.30 \
      minimap2 \
        -ax map-ont -L -z 400,200 -Y -t 20 \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ONT" \
        $REF $FASTQ/${SAMPLE}.fastq.gz \
    | podman run --rm -i \
      -v $PROJECT:/data:z \
      staphb/samtools:1.21 \
      samtools sort -@ 8 -o $OUT/${SAMPLE}.sorted.bam
    podman run --rm -v $PROJECT:/data:z staphb/samtools:1.21 \
      samtools index $OUT/${SAMPLE}.sorted.bam
    echo "$(date) - DONE: $SAMPLE"
done
echo "================================================"

# ============================================================
# TRIAL 2 — drop-s-80-to-40 (-z 400,200 + -s 40)
# ============================================================
OUT=/data/minimap-diff-parameters-trial/drop-s-80-to-40
echo "$(date) - TRIAL 2: drop-s-80-to-40"

for SAMPLE in sample-17-male sample-23-kid; do
    echo "$(date) - Starting: $SAMPLE"
    podman run --rm \
      -v $PROJECT:/data:z \
      staphb/minimap2:2.30 \
      minimap2 \
        -ax map-ont -L -z 400,200 -s 40 -Y -t 20 \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ONT" \
        $REF $FASTQ/${SAMPLE}.fastq.gz \
    | podman run --rm -i \
      -v $PROJECT:/data:z \
      staphb/samtools:1.21 \
      samtools sort -@ 8 -o $OUT/${SAMPLE}.sorted.bam
    podman run --rm -v $PROJECT:/data:z staphb/samtools:1.21 \
      samtools index $OUT/${SAMPLE}.sorted.bam
    echo "$(date) - DONE: $SAMPLE"
done
echo "================================================"

# ============================================================
# TRIAL 3 — drop-min-chain-score-40-to-20 (-z 400,200 + --min-chain-score 20)
# ============================================================
OUT=/data/minimap-diff-parameters-trial/drop-min-chain-score-40-to-20
echo "$(date) - TRIAL 3: drop-min-chain-score"

for SAMPLE in sample-17-male sample-23-kid; do
    echo "$(date) - Starting: $SAMPLE"
    podman run --rm \
      -v $PROJECT:/data:z \
      staphb/minimap2:2.30 \
      minimap2 \
        -ax map-ont -L -z 400,200 --min-chain-score 20 -Y -t 20 \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ONT" \
        $REF $FASTQ/${SAMPLE}.fastq.gz \
    | podman run --rm -i \
      -v $PROJECT:/data:z \
      staphb/samtools:1.21 \
      samtools sort -@ 8 -o $OUT/${SAMPLE}.sorted.bam
    podman run --rm -v $PROJECT:/data:z staphb/samtools:1.21 \
      samtools index $OUT/${SAMPLE}.sorted.bam
    echo "$(date) - DONE: $SAMPLE"
done
echo "================================================"

# ============================================================
# TRIAL 4 — drop-all (-z 400,200 + -s 40 + --min-chain-score 20)
# ============================================================
OUT=/data/minimap-diff-parameters-trial/drop-all
echo "$(date) - TRIAL 4: drop-all-parameters"

for SAMPLE in sample-17-male sample-23-kid; do
    echo "$(date) - Starting: $SAMPLE"
    podman run --rm \
      -v $PROJECT:/data:z \
      staphb/minimap2:2.30 \
      minimap2 \
        -ax map-ont -L -z 400,200 -s 40 --min-chain-score 20 -Y -t 20 \
        -R "@RG\tID:${SAMPLE}\tSM:${SAMPLE}\tPL:ONT" \
        $REF $FASTQ/${SAMPLE}.fastq.gz \
    | podman run --rm -i \
      -v $PROJECT:/data:z \
      staphb/samtools:1.21 \
      samtools sort -@ 8 -o $OUT/${SAMPLE}.sorted.bam
    podman run --rm -v $PROJECT:/data:z staphb/samtools:1.21 \
      samtools index $OUT/${SAMPLE}.sorted.bam
    echo "$(date) - DONE: $SAMPLE"
done
echo "================================================"

echo "$(date) - ALL FOUR TRIALS COMPLETE FOR S17 AND S23"

