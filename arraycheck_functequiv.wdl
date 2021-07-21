version 1.0

task stuart_arraycheck_functequiv {

	Int stuart_version = 0.0.0

	input {
		Array[File] test
		Array[File] truth
		Float? tolerance = 0.00000001  # 1.0e-8
	}

	Int test_size = ceil(size(test, "GB"))
	Int truth_size = ceil(size(truth, "GB"))
	Int finalDiskSize = test_size + truth_size + 1

	command <<<

	# the md5 stuff pulls from the files in /inputs/
	# the Rscript pulls from the copied files
	for j in ~{sep=' ' test}
	do
		
		# md5
		md5sum ${j} > sum.txt
		test_basename="$(basename -- ${j})"

		# R
		cp ${j} .
		mv ${test_basename} "testcopy_${test_basename}"

		for i in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${i})"
			if [ "${test_basename}" == "${truth_basename}" ]; then
				# md5
				actual_truth="$i"

				# R
				cp ${i} .
				mv ${truth_basename} "truthcopy_${truth_basename}"
				
				break
			fi
		done

		# md5
		if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
		then
			# R
			echo "Calling Rscript to check for functional equivalence."
			if Rscript /opt/rough_equivalence_check.R testcopy_$test_basename truthcopy_$truth_basename ~{tolerance}
			then
				echo "Outputs are not identical, but are mostly equivalent."
				# do not exit, check the others
			else
				echo "Outputs vary beyond accepted tolerance (default:1.0e-8)."
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