# CampWatchMe

CampWatchMe is a genomic analysis project focused on trio-based variant calling (Mother, Father, Child) using Oxford Nanopore Technologies (ONT) long-read sequencing data. The pipeline utilizes Minimap2 for alignment and DeepTrio for high-accuracy variant calling in a pedigree context.

## Project Overview

This project processes ONT long-read data from three related individuals to identify genetic variants. It handles the full workflow from raw (merged) FASTQ files to filtered and statistically analyzed VCF files.

### Samples
- **Sample 11**: Female, Parent 2 (Mother)
- **Sample 17**: Male, Parent 1 (Father)
- **Sample 23**: Child (Kid)

## Repository Structure

```
.
├── scripts/                # Shell scripts for alignment, variant calling, and stats
│   ├── alignment_repeat_req_flags.sh    # Main alignment script with optimized ONT flags
│   ├── deeptrio_output_run.sh          # DeepTrio variant calling execution
│   ├── vcf_stat_sample_*.sh            # Scripts for generating VCF stats reports
│   └── ...
├── extra/                  # QC and summary statistics
│   ├── samtools-coverage/  # Coverage reports per sample
│   ├── samtools-flagstat/  # Mapping statistics
│   └── samtools-idxstat/   # Alignment distribution across chromosomes
├── hg38/                   # Reference genome (GCA_000001405.15)
├── deeptrio_output/        # Directory for VCF and gVCF outputs
└── minimap-diff-parameters-trial/ # Experimental alignment parameter tests
```

## Workflow & Pipeline

### 1. Alignment
The project uses `minimap2` with specific presets for ONT data (`-ax map-ont`). The scripts include optimized parameters to handle long reads and complex genomic regions:
- `-L`: Moves long CIGAR strings to the `CG` tag.
- `-z 600,200`: Adjusted Z-score to prevent splitting of ultra-long reads.
- `-Y`: Uses soft-clipping for supplementary alignments.

### 2. Variant Calling
Variant calling is performed using **DeepTrio** (v1.10.0), which jointly analyzes the trio to improve accuracy and Mendelian consistency.
- **Model Type**: ONT
- **Reference**: GRCh38 (no alt analysis set)
- **Environment**: Optimized with specific thread and memory settings (`OPENBLAS_NUM_THREADS=1`, `MALLOC_ARENA_MAX=2`) to run efficiently on HPC environments.

### 3. Quality Control & Statistics
Post-calling analysis includes:
- `vcf_stats_report`: Visualizing variant quality and distribution.
- `samtools coverage/flagstat`: Verifying alignment quality and depth.

## Prerequisites

The pipeline is designed to run via **Podman** (or Docker) to ensure environment reproducibility.

### Required Container Images:
- `staphb/minimap2:2.30`
- `staphb/samtools:1.21`
- `google/deepvariant:deeptrio-1.10.0`

### Data Requirements:
- Reference Genome: `GCA_000001405.15_GRCh38_no_alt_analysis_set.fna`
- Merged FASTQ files for the trio.

## Usage

### Alignment
To run the alignment for all three samples:
```bash
./scripts/alignment_repeat_req_flags.sh
```

### Variant Calling
To run DeepTrio:
```bash
./scripts/deeptrio_output_run.sh
```

### Stats Generation
To generate VCF statistics for the kid:
```bash
./scripts/vcf_stat_sample_23_kid.sh
```
