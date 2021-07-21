version 1.0

task stuart_enumouse {
	input {
		String? genome_build
	}
	Boolean isdefined_genome = defined(genome_build)
	
	command <<<
		set -eux -o pipefail

		declare -A acceptable_genomes=( [hg38]=1  [hg19]=1  [hg19]=1 )
		test=~{genome_build}
		[[ -n "${acceptable_genomes[$test]}" ]] && printf '~{genome_build} is an acceptable input\n'
	>>>

	runtime {
		cpu: 2
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}
}