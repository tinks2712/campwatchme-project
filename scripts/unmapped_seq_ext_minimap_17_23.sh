#doing this step to run BLAST for unmapped reads from sample 17 and 23 , male and kid , which showed less than 50% alignment
#hhaha.. I didnt change project/bam file path , cuz earlier i was going to use podman to run
#ran samtools directly without using docker image but same version
#for sample 17 and 23 running this
#for loop


#f 4- flag to extract unmapped reads
#FLAG bit system::
#unmapped-4
#secondary -4 + 256
#supplementary -4 + 2048

#meaning, flag256 --secondary reads, flag2048 --supplemetary reads
#F0 is a flag if default is there , meaning it will discard unmapped secondary and supplementary reads
#by stating this F0 here meaning-- do not discard secondary and supplementary reads

#1--unmapped-4
#2--secondary -4 + 256
#3--supplementary -4 + 2048
#4-- mapped secondary - 256
#5--mapped supplementary -2048

#1,2,3 --- will pass -- will get reads from all these 3 categories
#4,5 ---discard -- since it is already mapped

#https://www.htslib.org/doc/samtools-fasta.html
#https://broadinstitute.github.io/picard/explain-flags.html

#output writing fasta-- directly usinf samtools fasta because runnning blast next
#-n is for not writing /1,/2 after in the header after queryID
#if i do not put -n -- it will write by default and that is for pair end seq/1,/2
#ONT is not pair end and that is why /1 and /2 wont come here, it also messes up with the actual header
#input bam file for father and kid

##after all this , there are 2 default flags are still there: -v --writes quality score, but since it is fasta format it wont write
#T/t - tag for reader's group, didnt keep

#for father's sample -unmapped reads --1556863 reads
#for kid's sample -unmapped reads --1637722 reads

PROJECT=/data1/campwatchme_project/campwatchme-project
BAM=$PROJECT/alignments/alignments_req_flags

for SAMPLE in sample-17-male sample-23-kid; do
    samtools fasta \
        -f 4 \
        -F 0 \
        -0 $BAM/${SAMPLE}.unmapped.fasta \
        -n \
        -@ 4 \
        $BAM/${SAMPLE}.sorted.bam
done


#output after running this in the terminal directly --
#[M::bam2fq_mainloop] discarded 0 singletons
#[M::bam2fq_mainloop] processed 1556863 reads

#[M::bam2fq_mainloop] discarded 0 singletons
#[M::bam2fq_mainloop] processed 1637722 reads


#M::bam2fq_mainloop -- is internal function that runs inside samtools bamfiles to fasta/q - M:message ::-seperator bam2fq..-internal function reportin

