# This is not a valid WDL. I'm not quite sure why. Compare to the functional wholet.wdl

version 1.0

struct Dog {
	String breed
	Float age_years
	Array[File] permit
}

task out {
	input {
		Dog who
	}
    command <<<
        echo "I can see a ~{who.breed} that is ~{who.age_years} years old"
        cat ~{sep='' who.permit}
    >>>

    runtime {
		docker: "ubuntu:latest"
		preemptible: 1
	}
}

workflow wholet {
	input {
		Array[Array[File]] files
	}

	Dog pompey = {"breed": "King Charles Cavalier Spaniel", "age_years": 4.5, "permit": files[0]}
	Dog gremlin = {"breed": "kind of weird terrier", "age_years": 0.3, "permit": files[1]}

	Array[Dog] thedogs = [pompey, gremlin]

    scatter(dog in thedogs) {
    	call out {
	        input:
	            who = dog
	    }
	}
}