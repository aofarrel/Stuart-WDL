version 1.1

workflow variable_update_value {
    input {
        Boolean thingy = true
    }
     Int A = 10
     Int B = -(A)
     if(thingy) {
        #A = 10 # unexpected token error
        #Int A = 10 # multiple declarations of A error
        Boolean false = !thingy
        Int B = -A
    }
    output {
        Int alpha = A
    }
    
}