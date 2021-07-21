version 1.0

task whisker {
    input {
        String echome
    }

    command <<<
        echo "${echome}"
    >>>

    output {
        String out = "The next task may now begin"
    }
}

task tail {
    input {
        String echome
    }

    command <<<
        echo "${echome}"
    >>>

    output {
        String out = "This should be the last task"
    }
}

workflow whiskertail {
	input {
		String bogus = "This doesn't ever get used"
	}
    call tail {
        input:
            echome = whisker.out
    }

    call whisker {
        input:
            echome = "I run first!"
    }
}