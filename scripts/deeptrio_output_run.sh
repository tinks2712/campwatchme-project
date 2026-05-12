#Running in the background with nohup command
#through podman
#first, got the image from docker hub-google/deepvariant:deeptrio-1.10.0
#model type selecting ONT- to see if it will work or not (if doesnt than pacbio)
#ref- hug38 no_alt_contig.fna
#paths for samples and ref
#output files paths for vcf anf gvcf
#num_shards 8()first kept 20 and didnt work-- it is like handling 8 jobs parallel manner

#on github they have selected region chr20 -i didnt since whole genome need to process and not just one specific region
#intermediate_results_dir for-- outputs of make_examples and call_variants stages can be found in the directory

#keeping these flags pids,openblas etc because pipeline was crashing and wasnt working

#pids-limit-podman flag that sets max number of process/thread per container is allowed to create, for deep trio generated hundreds of helper processes
#that is why it was crashing and podman had default 2048 or 4096 limit but I increased it to 8192 -for more room for the container

#OpenBLAS is a math library that DeepTrio uses for matrix operations
#default it detects 64 cores available and uses all of them according to num_shards
#ex num_shards=8, openblas-8*64=512, more thread for this process (first i kept num_shards-20 and openblas was on default gave error, since 20*64=1280 threads)
#OPENBLAS_NUM_THREADS=1 , forces openblas to use one thread only

#OMP- OpenMP is another parallelization library used by TensorFlow and other numerical libraries inside DeepTrio
#same it auto detects 64 cores and increase number of threads (earlier kept default and gave error)
#that is why OMP_NUM_THREADS=1

#MALLOC_ARENA - jemalloc/glibc malloc is the memory allocator
#it creates arenas-- (memory pools) per CPU core for thread-safe allocation
# and each arena has its own background thread - with 64 cores ,if kept default , get 64 arena*64 background thread
#earlier kept default and got  --jemalloc>: arena 0 background thread creation failed
#that is why MALLOC_ARENA_MAX=2

#-e sets enviornment in the container



nohup podman run \
  --rm \
  --pids-limit 8192 \
  -e OPENBLAS_NUM_THREADS=1 \
  -e OMP_NUM_THREADS=1 \
  -e MALLOC_ARENA_MAX=2 \
  -v "/data1/campwatchme_project/campwatchme-project":"/data" \
  google/deepvariant:deeptrio-1.10.0 \
  /opt/deepvariant/bin/deeptrio/run_deeptrio \
  --model_type ONT \
  --ref /data/hg38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna \
  --reads_child /data/alignments/alignments_req_flags/sample-23-kid.sorted.bam \
  --reads_parent1 /data/alignments/alignments_req_flags/sample-17-male.sorted.bam \
  --reads_parent2 /data/alignments/alignments_req_flags/sample-11-female.sorted.bam \
  --output_vcf_child /data/deeptrio_output/sample-23-kid.vcf.gz \
  --output_vcf_parent1 /data/deeptrio_output/sample-17-male.vcf.gz \
  --output_vcf_parent2 /data/deeptrio_output/sample-11-female.vcf.gz \
  --output_gvcf_child /data/deeptrio_output/sample-23-kid.g.vcf.gz \
  --output_gvcf_parent1 /data/deeptrio_output/sample-17-male.g.vcf.gz \
  --output_gvcf_parent2 /data/deeptrio_output/sample-11-female.g.vcf.gz \
  --sample_name_child 'Sample23-Kid' \
  --sample_name_parent1 'Sample17-Male' \
  --sample_name_parent2 'Sample11-Female' \
  --intermediate_results_dir /data/deeptrio_output/intermediate_results_dir \
  --num_shards 8 \
  > /data1/campwatchme_project/campwatchme-project/deeptrio_output/deeptrio_run.log 2>&1 &

echo "PID: $!"
