stuart_arraycheck_exact {

	input {
		Array[File] test
		Array[File] truth
		Float? tolerance = 0.00000001  # this equals 1.0e-8
		Boolean fastfail = false  # set to truth if we should exit out upon first mismatch
	}

	Int test_size = ceil(size(select_first([test, 0]), "GB"))
	Int truth_size = ceil(size(select_first([truth, 0]), "GB"))
	Int finalDiskSize = test_size + truth_size + 1

	command <<<
	for j in ~{sep=' ' test}
	do
		md5sum ${j} > sum.txt
		test_basename="$(basename -- ${j})"

		for i in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${i})"
			if [ "${test_basename}" == "${truth_basename}" ]; then
				actual_truth="$i"
				break
			fi
		done

		# md5
		if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
		then
			echo "Outputs are not identical, but are mostly equivalent."
			if ~{fastfail}
				exit 1
			fi
		fi
	done

	>>>

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}
}