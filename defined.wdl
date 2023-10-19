version 1.0

workflow Defined {
    input{
        Boolean run_task_beta = false
    }
    ############ WORKING AS EXPECTED: defined() on a non-scattered optional task's output #############
    if(run_task_beta) { 
        # false, so nonscattered_beta will never run
        call beta as nonscattered_beta 
    }
    # Task beta outputs non-optional String some_string, but since task beta is optional,
	# some_string is considered to have type String? now that we're outside the if-block.

	if (defined(nonscattered_beta.some_string)) {
	    # Because run_task_beta is false, nonscattered_beta.some_string is undefined,
	    # so first_gamma should also never run. And it doesn't, as we expect.
		call gamma as first_gamma {input: optional_string = nonscattered_beta.some_string}
	}
	
	############ COUNTERINTUTIVE: defined() on a scattered optional task's output ##################
    Array[String] nonsense = ["a", "b", "c"]
    scatter(char in nonsense) {
    	if(run_task_beta) { 
    	   # false, so this will never run
    	   call beta as scattered_beta 
    	}
    }
    # Outside the scatter block, the task's output is an array. But what kind of array?
    # Array[String]? <-- the array is optional but if it is defined its contents are required
    # Array[String?] <-- the array is required but it might contain nothing
    # I would be inclined to think Array[String]?, but...
	
	if (defined(scattered_beta.some_string)) {
		# This returns true in both miniwdl and Cromwell. Barring a serious bug with defined()
		# in both programs, that means that they must consider the scattered task's gathered
		# output to be Array[String?] instead of Array[String]?, and both of them created an
		# empty array antipacipating the optional task's output, so second_gamma DOES run.
		call gamma as second_gamma {
			input: 
				optional_array = scattered_beta.some_string,
				optional_string = scattered_beta.some_string[0]
		}
		# Consequences:
		#  1. Scattered tasks have blank output created for them, but non-scattered tasks do
		#     not, leading to inconsistencies. It doesn't make intutive sense for second_gamma
		#     to run when first_gamma does not run.
		#  2. You cannot use defined() to check if an optional scattered task ran.
	}
	
	############ PROBABLY BUGGED: making the scatter itself optional ##################
	# what happens if we flip the scatter and if(run_task_beta)?
	if(run_task_beta) { 
	    scatter(char in nonsense) {
    	   call beta as scattered_beta_flipped # still false, so this never runs
    	}
    }
    
    if (defined(scattered_beta_flipped.some_string)) {
        # miniwdl returns false, so third_gamma does not run, but Cromwell returns true, and then throws an error.
        # Either this is bugged in Cromwell, or there's a difference of interpretation of the WDL spec.
		call gamma as third_gamma {input: optional_string = scattered_beta_flipped.some_string[0]}
	}
}

task beta {
    
    command <<<
    echo "foo bar bizz buzz" >> deep_wisdom.txt
    >>>
    
    output {
        String some_string = read_string("deep_wisdom.txt")
    }
    
    runtime {
		cpu: 4
		disks: "local-disk 10 HDD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
}

task gamma {
    input { 
        Array[String?]? optional_array
        String? optional_string 
    }
    
    command <<<
    echo "~{sep=' ' optional_array}"
    echo "~{optional_string}"
    >>>
    
    runtime {
		cpu: 4
		disks: "local-disk 10 HDD"
		docker: "ashedpotatoes/usher-plus:0.0.2"
		memory: "4 GB"
		preemptible: 1
	}
	
	output { String status = "we ran gamma, with input ~{optional_string}" }
}