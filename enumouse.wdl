version 1.0

task stuart_enumouse {
	input {
		String? genome_build
	}
	Boolean isdefined_genome = defined(genome_build)
	
	command <<<
		set -eux -o pipefail

		declare -A array1=( [prova1]=1  [prova2]=1  [slack64]=1 )
		a=slack64
		[[ -n "${array1[$a]}" ]] && printf '%s is in array\n' "$a"
	>>>

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}
}