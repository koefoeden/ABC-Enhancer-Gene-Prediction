## call macs2 -- if multiple accessibility inputs for one biosample, will aggregate into one output
rule call_macs_peaks: 
	input:
	  custom_peaks = lambda wildcards: BIOSAMPLES_CONFIG.loc[wildcards.biosample, "atac_peaks_file"]
	conda:
		"../envs/abcenv.yml"
	output: 
		narrowPeak = os.path.join(RESULTS_DIR, "{biosample}", "Peaks", "macs2_peaks.narrowPeak")
	resources:
		mem_mb=determine_mem_mb
	shell: 
		"""
		cp {input.custom_peaks} {output.narrowPeak}
		"""

rule generate_chrom_sizes_bed_file:
	input:
		chrom_sizes = config['ref']['chrom_sizes']
	output:
		chrom_sizes_bed = os.path.join(RESULTS_DIR, "tmp", os.path.basename(config['ref']['chrom_sizes']) + '.bed')
	resources:
		mem_mb=determine_mem_mb
	shell:
		"""
		awk 'BEGIN {{OFS="\t"}} {{if (NF > 0) print $1,"0",$2 ; else print $0}}' {input.chrom_sizes} > {output.chrom_sizes_bed}
		"""

## sort narrowPeaks
rule sort_narrowpeaks:
	input:
		narrowPeak = os.path.join(RESULTS_DIR, "{biosample}", "Peaks", "macs2_peaks.narrowPeak"),
		chrom_sizes_bed = os.path.join(RESULTS_DIR, "tmp", os.path.basename(config['ref']['chrom_sizes']) + '.bed')
	params:
		chrom_sizes = config['ref']['chrom_sizes']
	conda:
		"../envs/abcenv.yml"
	output:
		narrowPeakSorted = os.path.join(RESULTS_DIR, "{biosample}", "Peaks", "macs2_peaks.narrowPeak.sorted")
	resources:
		mem_mb=determine_mem_mb
	shell:
		"""
		# intersect to remove alternate chromosomes
		bedtools intersect -u -a {input.narrowPeak} -b {input.chrom_sizes_bed} | \
		bedtools sort -faidx {params.chrom_sizes} -i stdin > {output.narrowPeakSorted}
		"""
