version 1.0

# Mickey and Minnie
#
# This workflow is an example of the pair() input type. It is based upon
# an LD pruning workflow, but should not be used for actual scientific
# analysis -- use this instead:
# https://dockstore.org/workflows/github.com/DataBiosphere/analysis_pipeline_WDL/ld-pruning-wdl

task ld_pruning {
	input {
		File gds_file

		# runtime attributes
		Int addldisk = 5
		Int cpu = 2
		Int memory = 4
		Int preempt = 3
	}

	# Estimate disk size required
	Int gds_size = ceil(size(gds_file, "GB"))
	Int final_disk_dize = gds_size + addldisk

	command {
		set -eux -o pipefail

		# Generate a configuration file -- this is specific to the R script that this
		# task uses; generally, you wouldn't do this for most workflows.
		python << CODE
		import os
		f = open("ld_pruning.config", "a")
		f.write('gds_file "~{gds_file}"\n')
		f.write('genome_build hg38\n')

		# The R script expects the GDS files to contain "chr*" where * is chr number/X/Y,
		# so use some string manipulation to determine the output file name. Again, this
		# is one of those tricks that is specific to this particular R script.
		if "chr" in "~{gds_file}":
			parts = os.path.splitext(os.path.basename("~{gds_file}"))[0].split("chr")
			outfile_temp = "pruned_variants_chr" + parts[1] + ".RData"
		else:
			outfile_temp = "pruned_variants.RData"
		f.write('out_file "' + outfile_temp + '"\n')
		f.close()
		CODE

		echo "Calling R script ld_pruning.R"
		Rscript /usr/local/analysis_pipeline/R/ld_pruning.R ld_pruning.config
	}

	runtime {
		cpu: cpu
		docker: "uwgac/topmed-master@sha256:0bb7f98d6b9182d4e4a6b82c98c04a244d766707875ddfd8a48005a9f5c5481e"
		disks: "local-disk " + final_disk_dize + " HDD"
		memory: "${memory} GB"
		preemptible: "${preempt}"
	}
	output {
		File ld_pruning_output = glob("*.RData")[0]
	}

}

task echo_pairs {
	input {
		Pair[File, File] gds_n_varinc  # [gds, variants to prune]

		# runtime attributes
		Int addldisk = 5
		Int cpu = 2
		Int memory = 4
		Int preempt = 3
	}
	
	# Estimate disk size required
	Int gds_size = ceil(size(gds_n_varinc.left, "GB"))
	Int final_disk_dize = gds_size + addldisk
	
	command {
		
		echo "GDS file: ~{gds_n_varinc.left}\n\n"
		echo "Resulting variant file it output: ~{gds_n_varinc.right}\n\n"
		echo "We can now call another R script to subset each GDS file via the variants file..."
		echo "...but we won't, because I want to encourage you to use this workflow instead:"
		echo "https://dockstore.org/workflows/github.com/DataBiosphere/analysis_pipeline_WDL/ld-pruning-wdl"

	}

	runtime {
		cpu: cpu
		docker: "uwgac/topmed-master@sha256:0bb7f98d6b9182d4e4a6b82c98c04a244d766707875ddfd8a48005a9f5c5481e"
		disks: "local-disk " + final_disk_dize + " HDD"
		memory: "${memory} GB"
		preemptibles: "${preempt}"
	}
}



workflow mickey_and_minnie {
	input {
		Array[File] gds_files
	}

	scatter(gds_file in gds_files) {
		call ld_pruning {
			input:
				gds_file = gds_file
		}
	}

	# CWL uses a dotproduct scatter; this is the closest WDL equivalent
	scatter(gds_n_varinc in zip(gds_files, ld_pruning.ld_pruning_output)) {
		call echo_pairs {
			input:
				gds_n_varinc = gds_n_varinc
		}
	}

	meta {
		author: "Ash O'Farrell"
		email: "aofarrel@ucsc.edu"
	}
}