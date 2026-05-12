#!/bin/bash

# ============================================================
# CampWatchMe - Minimap2 Alignment Script
# Sample 11 - Female, Parent  (flow cell PBI66128)
# Total bases: 83.4 GB | Reads: 14.33M | Q10: 93.5% | N50: 9826bp
# ============================================================

# Define pathways
PROJECT=/data1/campwatchme_project/campwatchme-project
REF=/data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
FASTQ=/data/merged_fastq
OUT=/data/alignments

echo "$(date) - Starting alignment: sample-11-female"

# podman run command
# staphb/minimap2:2.30 - image pulled from Docker Hub
# --rm - clean up container after it finishes
# -v - volume mount: connects server folder into container
#   $PROJECT = real path on server
#   /data = what container calls it
#   :z = SELinux permission flag for HPC servers
# minimap2 -ax map-ont:
#   -a = output SAM format (what samtools and DeepTrio understand)
#   -x map-ont = ONT long read preset
# -t 20 = 20 CPU threads
# -R read group tag required by DeepTrio:
#   @RG = read group header in BAM file
#   \t = tab separator (BAM format requirement)
#   ID:S11 = short unique identifier for this sample
#   SM:sample-11-female = sample name DeepTrio uses for trio calling
#   PL:ONT = sequencing platform
# $REF = hg38 reference genome downloaded from NCBI
# $FASTQ/sample-11-female.fastq.gz = mother (Parent 2) reads
# | pipe: streams minimap2 output directly into samtools
# samtools sort: sorts reads by genomic coordinate
# -@ 8 = 8 threads for sorting
# -o = output BAM file path
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/minimap2:2.30 \
  minimap2 \
    -ax map-ont \
    -t 20 \
    -R '@RG\tID:S11\tSM:sample-11-female\tPL:ONT' \
    $REF \
    $FASTQ/sample-11-female.fastq.gz \
| podman run --rm -i \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools sort -@ 8 -o $OUT/sample-11-female.sorted.bam

# samtools index: creates .bai index file alongside BAM
# required by DeepTrio to jump to any genome position instantly
podman run --rm \
  -v $PROJECT:/data:z \
  staphb/samtools:1.21 \
  samtools index $OUT/sample-11-female.sorted.bam

echo "$(date) - DONE: sample-11-female"
echo "================================================"


