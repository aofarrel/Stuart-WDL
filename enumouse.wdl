version 1.0

task stuart_enumouse {
	input {
		String? genome_build
	}
	Boolean isdefined_genome = defined(genome_build)
	
	command <<<
		set -eux -o pipefail

		python << CODE
		if isdefined_genome:
			if "~{genome_build}" not in ['hg19', 'hg38']:
				print("Invalid ref genome. Please only select either hg38 or hg19.")
				exit(1)
		CODE
	>>>
}