#running this because saw this on git and wanted to try for these samples
#https://github.com/google/deepvariant/blob/r1.10/docs/deepvariant-vcf-stats-report.md
#again need same docker image deepvariant/deeptrio 1.10.0
#input mother sample vcf file
#-v mounting volume flag --simce docker container is isolated and can not see files directly --creating a pathway for files and docker



podman run \
  -v "/data1/campwatchme_project/campwatchme-project/deeptrio_output:/input" \
  -v "/data1/campwatchme_project/campwatchme-project/deeptrio_output/vcf_stats_reports:/output" \
  google/deepvariant:deeptrio-1.10.0 \
  /opt/deepvariant/bin/vcf_stats_report \
  --input_vcf /input/sample-11-female.vcf.gz \
  --outfile_base /output/sample-11-female_stats \
  --title "Sample-11-Female (CampWatchMe trio)"
