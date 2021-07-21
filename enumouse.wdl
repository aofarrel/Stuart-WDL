version 1.0

task stuart_enumouse {
	input {
		String? genome_build
	}
	Boolean isdefined_genome = defined(genome_build)
	
	command <<<
		set -eux -o pipefail

		declare -A array1=( [hg38]=1  [hg19]=1  [hg19]=1 )
		a=${genome_build}
		[[ -n "${array1[$a]}" ]] && printf '%s is in array\n' "$a"
	>>>

	runtime {
		cpu: 2
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}
}