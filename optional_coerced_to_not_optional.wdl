version 1.0

workflow Nifty_Workaround {
    input{
        File always_exists
        File? some_input
        File? some_metadata
        Boolean matutils_something = true
    }

    # if we want to use matutils...
	if((matutils_something)) {
	    
	    # and the input exists...
		if (defined(some_input)) {

			# and metadata exists...
			if (defined(some_metadata)) {
				call annotate as annotate_optional_input {
					input:
					    # some_input and some_metadata have type File?. In order to get to this if block,
					    # they must be defined. We can therefore use select_first() with a bogus fallback
					    # value to coerce the File?s into Files.
						thing_to_annotate = select_first([some_input, always_exists]),
						metadata = select_first([some_metadata, always_exists]),
				}
			}

            # This block executes if we want to summarize the input, and the input exists, but the input
            # may or may not have been annotated.
            
			File possibly_annotated_input = select_first([annotate_optional_input.annotated_output, some_input])

			call word_count as word_count_input {
				input:
					thing_to_word_count = possibly_annotated_input
			}
		}

		# We want to use matutils, but the some_input may or may not exist. If some_input exists, we
		# want to run matutils on it. if some_input exists and also has been annotated, we want to
		# use the annotated version. if some_input does not exist, we want to fall back to a file that
		# already exists in the Docker image used by the task.
	}


}

task annotate {
    input {
        File thing_to_annotate
        File metadata
        Int addl_disk_space = 10
	}
	Int disk_size = ceil(size(thing_to_annotate, "GB")) + ceil(size(thing_to_annotate, "GB")) + addl_disk_space
    
    command <<<
    # in the real pipeline this base case is mimicking, this is where a phylogenetic tree gets annotated
    # for the sake of demonstration of the bug we're just going to do some nonsense
    cat ~{thing_to_annotate} ~{metadata} >> annotated.txt
    >>>
    
    output {
        File annotated_output = "annotated.txt"
    }
    
    runtime {
		cpu: 4
		disks: "local-disk " + disk_size + " SSD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
}

task count_lines {
    input { 
        File thing_with_lines_to_count
        Int addl_disk_space = 10
    }
	Int disk_size = ceil(size(thing_with_lines_to_count, "GB")) + addl_disk_space
    
    command <<<
    wc -l ~{thing_with_lines_to_count} >> line_count.txt
    >>>
    
    output {
        File line_count = "line_count.txt"
    }
    
    runtime {
		cpu: 4
		disks: "local-disk " + disk_size + " SSD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
}

task do_something_to_input_or_some_file_already_in_docker_image {
    input { 
        File? something_that_might_exist
        Int addl_disk_space = 10
    }
    Int disk_size = if defined(something_that_might_exist) then ceil(size(something_that_might_exist, "GB")) + addl_disk_space else addl_disk_space
    
    command <<<
    if [[ "~{something_that_might_exist}" = "" ]]
	then
		i="/HOME/usher/example_tree/tb_alldiffs_mask2ref.L.fixed.pb"
	else
		i="~{something_that_might_exist}"
	fi

	matUtils summary -i "$i" > "matutils_summary.txt"
    >>>
    
    output {
        File matutils_output = "matutils_summary.txt"
    }
    
    runtime {
		cpu: 4
		disks: "local-disk " + disk_size + " SSD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
}