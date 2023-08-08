version 1.0

workflow put_string_in_terra_column {
    input {
        File fastq
    }
    
    Boolean always_true_but_WDL_does_not_know_that = true
    Array[File] one_element_array = [fastq]
    
    scatter(one_fastq in one_element_array) {
        if(always_true_but_WDL_does_not_know_that) {
            call make_first_error_code
        }
    }
    
    if(defined(make_first_error_code.errorcode)) {                   # did the decontamination step actually run?
		
			call debug as read_first_error_code {
				input:
					all_errors = make_first_error_code.errorcode,
					index_zero_error = make_first_error_code.errorcode[0]
			}
		
			#if(!(make_first_error_code.errorcode[0] == pass)) {          # did the decontamination step return an error?
			#	String decontam_ERR = decontam_each_sample.errorcode[0] # get the first (0th) value, eg only value since there's just one sample
			#}
		}
}

task make_first_error_code {
    input {
        Boolean error = true
    }
    
    command <<<
    if [[ "~{error}" = "true" ]]
    then
        echo "FIRST_DEBUG_ERROR" >> ERROR
        exit 0
    fi 
    
    >>>
    
    runtime {
		cpu: 2
		docker: "ashedpotatoes/iqbal-unofficial-clockwork-mirror:v0.11.3"
		disks: "local-disk " + 10 + " HDD"
		memory: "4 GB"
		preemptible: "1"
	}
    
    output {
        String errorcode = read_string("ERROR")
    }
}

task debug {
	input {
		Array[String?]? all_errors
		String? index_zero_error
	}
	
	command  <<<
	echo "~{sep=' ' all_errors}"
	echo "~{index_zero_error}"
	>>>
	
	runtime {
		cpu: 2
		docker: "ashedpotatoes/iqbal-unofficial-clockwork-mirror:v0.11.3"
		disks: "local-disk " + 10 + " HDD"
		memory: "4 GB"
		preemptible: "1"
	}
}