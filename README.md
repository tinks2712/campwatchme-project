# CampWatchMe: ONT Trio-Based Variant Calling Pipeline

CampWatchMe is a specialized genomic analysis project designed for pedigree-based variant calling using **Oxford Nanopore Technologies (ONT)** long-read sequencing. The project integrates high-performance alignment strategies with **DeepTrio** to achieve high-accuracy variant detection across a familial trio (Mother, Father, and Child).

## Project Overview

The pipeline processes ONT data from raw FASTQ through to annotated VCFs, with a focus on overcoming challenges specific to long-read data such as ultra-long read alignment and computational overhead in deep learning-based variant callers.

### Sample Metadata & QC
| Sample ID | Role | Flow Cell | Total Bases | Reads | Q10 | N50 | Notes |
|-----------|------|-----------|-------------|-------|-----|-----|-------|
| Sample 11 | Mother (P2) | PBI66128 | 83.4 GB | 14.33M | 93.5% | 9,826 bp | High coverage |
| Sample 17 | Father (P1) | PBK21011 | 27.8 GB | 4.46M | 73.6% | 14,682 bp | Flow cell defect |
| Sample 23 | Child (Kid) | PBK15059 | 21.1 GB | 3.68M | 83.7% | 11,425 bp | Flow cell defect |

## Repository Structure

```
.
├── scripts/                # Shell scripts for alignment, variant calling, and stats
│   ├── alignment_repeat_req_flags.sh    # Main alignment script with optimized ONT flags
│   ├── deeptrio_output_run.sh          # DeepTrio execution with environment tuning
│   ├── unmapped_seq_ext_minimap_17_23.sh # Extraction of unmapped reads for BLAST
│   └── vcf_stat_sample_*.sh            # VCF statistics and reporting
├── extra/                  # QC and summary statistics
│   ├── samtools-coverage/  # Coverage depth per chromosome
│   ├── samtools-flagstat/  # Mapping quality statistics
│   └── samtools-idxstat/   # Read distribution per contig
├── hg38/                   # Reference genome (GCA_000001405.15 no-alt analysis set)
├── deeptrio_output/        # Final VCF and gVCF outputs
└── minimap-diff-parameters-trial/ # Parameter benchmarking for alignment optimization
```

## Technical Workflow

### 1. Optimized ONT Alignment
Using `minimap2` (v2.30), we apply specific flags to handle the unique characteristics of ONT long reads:
- `-ax map-ont`: Preset for Oxford Nanopore data.
- `-L`: Moves long CIGAR strings (>65535 operations) to the `CG` tag, ensuring compatibility with standard BAM tools.
- `-z 600,200`: Increases the Z-drop score from the default 400. This prevents the splitting of ultra-long reads in regions with high insertion/deletion rates.
- `-Y`: Enables soft-clipping for supplementary alignments, preserving unaligned bases for downstream analysis.

### 2. Alignment Parameter Benchmarking
To address the lower alignment rates observed in Samples 17 and 23, several experimental parameter sets were tested in `minimap-diff-parameters-trial/`:

| Trial | Name | Parameters Tested | Purpose |
|-------|------|-------------------|---------|
| Trial 1 | `drop-z-score` | `-z 400,200` | Testing standard Z-drop score vs optimized 600. |
| Trial 2 | `drop-s-80-to-40` | `-z 400,200 -s 40` | Loosening minimal peak SW score (default 80) to 40. |
| Trial 3 | `drop-min-chain-score` | `-z 400,200 --min-chain-score 20` | Reducing min chain score (default 40) to 20. |
| Trial 4 | `drop-all` | `-z 400,200 -s 40 --min-chain-score 20` | Combined loosening of Z-drop, SW score, and chain score. |

These trials help determine if more permissive alignment settings improve coverage in samples with flow cell defects without introducing excessive noise.

### 3. DeepTrio Variant Calling (v1.10.0)
DeepTrio jointly analyzes the trio to improve Mendelian consistency. Due to the high computational demand, the environment is tuned for HPC stability:
- **PID Limit (`--pids-limit 8192`)**: DeepTrio generates hundreds of helper processes; increasing this prevents container crashes.
- **Thread Management**: `OPENBLAS_NUM_THREADS=1` and `OMP_NUM_THREADS=1` are set to prevent thread explosion (exponentially increasing threads across shards), which can lead to "Resource temporarily unavailable" errors.
- **Memory Allocation**: `MALLOC_ARENA_MAX=2` limits the number of memory pools, preventing overhead and background thread creation failures in `jemalloc`.
- **Parallelization**: `num_shards` is set to 8 to balance throughput and resource constraints.

### 4. Handling Unmapped Reads
For samples with lower alignment rates (Sample 17 and 23), unmapped reads are extracted for further investigation (e.g., BLAST analysis) to identify potential contaminants or non-human sequences:
- `samtools fasta -f 4 -F 0`: Specifically extracts unmapped reads while retaining secondary/supplementary info.

## Prerequisites & Environment

The pipeline is fully containerized using **Podman** for reproducibility and security.

### Images
- `staphb/minimap2:2.30`
- `staphb/samtools:1.21`
- `google/deepvariant:deeptrio-1.10.0`

### Security
The DeepTrio image has been scanned using `Trivy` (see `deeptrio-trial/trivy_deeptrio_scan.txt`) to monitor vulnerabilities in the deep learning stack.

## Usage Instructions

### Run Alignment
```bash
bash scripts/alignment_repeat_req_flags.sh
```

### Run Variant Calling
DeepTrio runs in the background using `nohup`. Logs are directed to `deeptrio_output/deeptrio_run.log`.
```bash
bash scripts/deeptrio_output_run.sh
```

### Run Parameter Trials
```bash
bash minimap-diff-parameters-trial/rerun_missing_samples.sh
```

### Extract Unmapped Reads
```bash
bash scripts/unmapped_seq_ext_minimap_17_23.sh
```
