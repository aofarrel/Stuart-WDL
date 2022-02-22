version 1.0

# Use parserissues.json

# As of Cromwell 76, this will pass successfully, although what
# it actually writes to foo.txt is the name of a temp file. It is
# the temp file itself that lists the input "bam" files.
task precisely_as_it_is_in_the_spec {
  input {
    Array[File] bams
  }
  command {
    echo ${write_lines(bams)} > foo.txt
  }
}

# As of Cromwell 76, this will throw a bad substitution error
task as_above_but_with_carrots {
  input {
    Array[File] bams
  }
  command <<<
    echo ${write_lines(bams)} > foo.txt
  >>>
}

# As of Cromwell 76, this will throw a bad substitution error
task marcs_version {
	input {
    Array[File] infiles
  }
	command <<<
    set -e
    cat ${write_lines(infiles)} > subtree_urls.txt
    >>>
}

# As of Cromwell 76, this will not error out, but it doesn't seem
# to actually make a JSON file. It's another temp file with no key-value
# pairs, just a JSON-compatiable array. Strictly speaking that would be
# valid JSON if it had the right extension...?
task make_a_json {
  input {
    Array[File] bams
  }
  command {
    echo ${write_json(bams)} > foo.txt
  }
}

workflow parserissues {
	input {
		Array[File] bam_files
	}

	call precisely_as_it_is_in_the_spec {
		input:
			bams = bam_files
	}

	#call as_above_but_with_carrots {
	#	input:
	#		bams = bam_files
	#}

	#call marcs_version {
	#	input:
	#		infiles = bam_files
	#}

	call make_a_json {
		input:
			bams = bam_files
	}

	meta {
		author: "Ash O'Farrell"
		email: "aofarrel@ucsc.edu"
	}
}

