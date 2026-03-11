rule make_candidate_regions:
	input:
		custom_peaks = lambda wildcards: BIOSAMPLES_CONFIG.loc[wildcards.biosample, "atac_candidate_region_BEDs"]
	output: 
		candidateRegions = os.path.join(RESULTS_DIR, "{biosample}", "Peaks", "macs2_peaks.narrowPeak.sorted.candidateRegions.bed")
	shell: 
		"""
		cp {input.custom_peaks} {output.candidateRegions}
		"""
