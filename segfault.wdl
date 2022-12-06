version 1.0

# Divide a bunch of file (or rather strings indicating their URLs/URIs) inputs
# into "segments." This is useful for controlling how many times you want to
# scatter a task.

task segfault {
	input {
		Array[String] inputs
		Int n_segments
	}

	command <<<
	python3 << CODE
	import numpy as np
	files = ["~{sep='","' inputs}"]
	print(f"There's a total of {len(files)} inputs to segment.")
	with open("segments.tsv", "w") as file:
		for array in np.array_split(files, ~{n_segments}):
			print(array)
			file.writelines("\t".join(array) + "\n")
	CODE
	>>>

	runtime {
		docker: "ashedpotatoes/sranwrp:1.1.0"
		memory: "4 GB"
	}

	output {
		Array[Array[String]] segments = read_tsv("segments.tsv")
		File segments_files = "segments.tsv"
	}
}
