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

workflow parserissues {
	input {
		Array[File] bam_files
	}

	call precisely_as_it_is_in_the_spec {
		input:
			bams = bam_files
	}

	call as_above_but_with_carrots {
		input:
			bams = bam_files
	}

	meta {
		author: "Ash O'Farrell"
		email: "aofarrel@ucsc.edu"
	}
}

