podman run \
  -v "/data1/campwatchme_project/campwatchme-project/deeptrio_output:/input" \
  -v "/data1/campwatchme_project/campwatchme-project/deeptrio_output/vcf_stats_reports:/output" \
  google/deepvariant:deeptrio-1.10.0 \
  /opt/deepvariant/bin/vcf_stats_report \
  --input_vcf /input/sample-17-male.vcf.gz \
  --outfile_base /output/sample-17-male_stats \
  --title "Sample-17-Male (CampWatchMe trio)"

