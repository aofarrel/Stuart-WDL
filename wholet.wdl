version 1.0

struct Dog {
	String breed
	Float age_years
}

task out {
	input {
		Dog who
	}
    command <<<
        echo "I can see a ~{who.breed} that is ~{who.age_years} years old"
    >>>
}

workflow wholet {

	Dog pompey = {"breed": "King Charles Cavalier Spaniel", "age_years": 4.5}
	Dog gremlin = {"breed": "kind of weird terrier", "age_years": 0.3}

	Array[Dog] thedogs = [pompey, gremlin]

    scatter(dog in thedogs) {
    	call out {
	        input:
	            who = dog
	    }
	}
}