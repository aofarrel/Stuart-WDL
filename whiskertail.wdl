version 1.0

task simpletask {
    input {
        String echome
    }

    command <<<
        echo "${echome}"
    >>>

    output {
        String out = "The next task may now begin!"
    }
}

workflow whiskertail {
	input {
		String bogus = "This doesn't ever get used, but an input is required for some backends."
	}

    if(back_paws.out != "") {
        call simpletask as tail {
            input:
                echome = "I run last!"
        }
    }

    call simpletask as front_paws {
        input:
            echome = whisker.out
    }

    call simpletask as whisker {
        input:
            echome = "I run first!"
    }

    if(front_paws.out != "") {
        call simpletask as back_paws {
            input:
                echome = "I am the penultimate task!"
        }
    }
}