#!/bin/bash

# ============================================================
# CampWatchMe - Minimap2 Alignment via PODMAN
# Sample 17 - Male, Parent 1 (flow cell PBK21011) - flow cell defect
# Total base - 27.8 GB
# Reads - 4.46 m
# Q 10 -73.6 %
# N50- 14682
# Sample 23 - Child (flow cell PBK15059) - flow cell defect
# Total base- 21.1 GB
# Reads -3.68 M
# Q 10 - 83.7%
# N50 - 11425
# Tool: minimap2 v2.30 | samtools v1.21 via podman

# ============================================================

# Define pathways
# PROJECT = real path on server
# REF, FASTQ, OUT = container paths (/data = $PROJECT inside container)
PROJECT=/data1/campwatchme_project/campwatchme-project
REF=/data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
FASTQ=/data/merged_fastq
OUT=/data/alignments

# ============================================================
# SAMPLE 17 - Male, Parent 1 (flow cell PBK21011)
# Note: flow cell defect - lower coverage
# ============================================================

echo "$(date) - Starting PODMAN alignment: sample-17-male"

# minimap2 via podman container
# -ax map-ont: ONT long read preset, outputs SAM format
# -t 20: 20 CPU threads
# -R read group tag: required by DeepTrio for trio calling
#   ID:S17 = unique identifier for father sample
#   SM:sample-17-male = sample name DeepTrio uses
#   PL:ONT = Oxford Nanopore platform
# pipe into samtools sort for coordinate sorting
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -t 20 \
    -R '@RG\tID:S17\tSM:sample-17-male\tPL:ONT' \
    $REF \
    $FASTQ/sample-17-male.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-17-male.sorted.bam

# index BAM - creates .bai file required by DeepTrio
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-17-male.sorted.bam

echo "$(date) - DONE: sample-17-male"
echo "================================================"

# ============================================================
# SAMPLE 23 - Child (flow cell PBK15059)
# Note: flow cell defect - lower coverage - boss approved
# ============================================================

echo "$(date) - Starting PODMAN alignment: sample-23-kid"

# same command structure as sample-17-male
# only ID, SM, and filenames change between samples
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -t 20 \
    -R '@RG\tID:S23\tSM:sample-23-kid\tPL:ONT' \
    $REF \
    $FASTQ/sample-23-kid.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-23-kid.sorted.bam

# index BAM
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-23-kid.sorted.bam

echo "$(date) - DONE: sample-23-kid"
echo "================================================"

