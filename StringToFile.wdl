version 1.0

workflow I_Guess_You_Could_Do_This {
    input { String refgenome }
    
    call index_genome {
        input: 
            refgenome = refgenome
    }
}

task index_genome {
    input { File refgenome }
    command <<< samtools index ~{refgenome} >>>
    output { File index = "~{refgenome}.fai" }
}