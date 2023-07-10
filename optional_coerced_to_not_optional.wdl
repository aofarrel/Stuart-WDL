version 1.0

workflow Nifty_Workaround {
    input{
        File always_exists
        File? some_input
        File? some_metadata
        Boolean summarize_input_if_it_exists = true
    }

    # if we want to summarize the input...
	if((summarize_input_if_it_exists)) {
	    
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

            # this block executes if we want to summarize the input, and the input exists, but the input
            # may or may not have been annotated.
			File possibly_annotated_input = select_first([annotate_optional_input.annotated_output, some_input])

			call summarize as summarize_input {
				input:
					thing_to_summarize = possibly_annotated_input
			}
		}
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

task summarize {
    input { 
        File? thing_to_summarize # yes, type File?, because we want to fallback to something in the Docker image if not defined
        Int addl_disk_space = 10
    }
    Int disk_size = if defined(thing_to_summarize) then ceil(size(thing_to_summarize, "GB")) + addl_disk_space else addl_disk_space
    
    command <<<
    wc -l ~{thing_to_summarize} >> line_count.txt
    >>>
    
    output {
        File summarized_output = "line_count.txt"
    }
    
    runtime {
		cpu: 4
		disks: "local-disk " + disk_size + " SSD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
}