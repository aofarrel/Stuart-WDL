version 1.0

workflow put_string_in_terra_column {
    input {
        File fastq
    }
    
    String? decontam_ERR = "foo"
    String? varcall_ERR = "bar"
    String pass = "PASS"
    
    output {
        String put_me_in_there = select_first([decontam_ERR, varcall_ERR, pass])
    }
}