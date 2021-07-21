version 1.0

task stuart_enumouse {
	input {
		String? genome_build
	}
	Boolean isdefined_genome = defined(genome_build)
	
	command <<<
		set -eux -o pipefail

		declare -A acceptable_genomes=( [hg38]=38  [hg18]=18  [hg19]=19 )
		test="~{genome_build}"
		if [ -z ${acceptable_genomes[$test]+x} ]
		then
			echo "$test is not an acceptable value."
			exit 1
		else
			echo "$test is an acceptable value."
			exit 0
		fi
	>>>

	runtime {
		cpu: 2
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}
}