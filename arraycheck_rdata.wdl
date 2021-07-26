version 1.0

task stuart_arraycheck_rdata {

	input {
		Array[File] test
		Array[File] truth
		Float? tolerance = 0.00000001  # 1.0e-8, only matters if exact==false
		Boolean exact = false  # should we only check for md5 equivalence?
		Boolean fastfail = false  # should we exit as soon as we get our first mismatch?
	}

	Int test_size = ceil(size(test, "GB"))
	Int truth_size = ceil(size(truth, "GB"))
	Int finalDiskSize = test_size + truth_size + 1

	command <<<

	failflag=false
	for j in ~{sep=' ' test}
	do
		md5sum ${j} > sum.txt
		test_basename="$(basename -- ${j})"

		for i in ~{sep=' ' truth}
		do
			truth_basename="$(basename -- ${i})"

			# We assume the test file and truth file have the same basename
			# Due to how WDL input work, they have a different absolute path
			if [ "${test_basename}" == "${truth_basename}" ]; then
				actual_truth="$i"
				break
			fi
		done

		if ! echo "$(cut -f1 -d' ' sum.txt)" $actual_truth | md5sum --check
		then
			if ! ~{exact}
			then
				echo "Calling Rscript to check for functional equivalence."
				if Rscript /opt/rough_equivalence_check.R $j $actual_truth ~{tolerance}
				then
					echo "Outputs are not identical, but are mostly equivalent."
				else
					echo "Outputs vary beyond accepted tolerance (default:1.0e-8)."
					failflag=true
					if ~{fastfail}
					then
						exit 1
					fi
				fi
			else
				failflag=true
				if ~{fastfail}
				then
					exit 1
				fi
			fi
		fi
	done

	if ${failflag}
	then
		exit 1
	fi

	>>>

	runtime {
		cpu: 2
		disks: "local-disk " + finalDiskSize + " HDD"
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2
	}

}