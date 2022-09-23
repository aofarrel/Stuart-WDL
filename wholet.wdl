version 1.0

struct Dog {
	String breed
	Float age_years
	File permit
}

task out {
	input {
		Dog who
	}
    command <<<
        echo "I can see a ~{who.breed} that is ~{who.age_years} years old"
        cat ~{who.permit}
    >>>

    runtime {
		docker: "ubuntu:latest"
		preemptible: 1
	}
}

workflow wholet {
	input {
		File pompey_permit
		File gremlin_permit
	}

	Dog pompey = {"breed": "King Charles Cavalier Spaniel", "age_years": 4.5, "permit": pompey_permit}
	Dog gremlin = {"breed": "kind of weird terrier", "age_years": 0.3, "permit": gremlin_permit}

	Array[Dog] thedogs = [pompey, gremlin]

    scatter(dog in thedogs) {
    	call out {
	        input:
	            who = dog
	    }
	}
}