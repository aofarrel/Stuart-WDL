version 1.0

workflow defined_or_not {
    String pass = "PASS"
    Boolean do_not_run_qc = true
    Boolean always_true = true 
    
    if(!do_not_run_qc) {
        call qc
        if(always_true) {
            if(!(qc.pass_or_fail == pass)) {
                String qc_error_code = qc.pass_or_fail
            }
        }
    }
    
    if (defined(qc_error_code)) {
        String error_code_coerced_to_not_optional = select_first([qc.pass_or_fail, "WORKFLOW_ERROR_8_REPORT_TO_DEV"])
        call print { input: echo_this = error_code_coerced_to_not_optional }
    }
}

task qc {
    input {
        String? unused_string  # sometimes tasks without an input get buggy
    }
    
    command <<<
    if (( $RANDOM > 25000 ))
    then
        echo "FAILED_QC" >> ERROR
        exit 0
    else
        echo "PASS" >> ERROR
        exit 0
    fi
    >>>
    
    output { String pass_or_fail = read_string("ERROR") }
    
    runtime {
        cpu: 2
        docker: "ashedpotatoes/clockwork-plus:v0.11.3.2-full"
        disks: "local-disk 10 HDD"
        memory: "2 GB"
        preemptible: "1"
    }
}

task print {
    input {
        String echo_this
    }
    
    command <<<
    echo "~{echo_this}"
    >>>
    
    runtime {
        cpu: 2
        docker: "ashedpotatoes/clockwork-plus:v0.11.3.2-full"
        disks: "local-disk 10 HDD"
        memory: "2 GB"
        preemptible: "1"
    }
}