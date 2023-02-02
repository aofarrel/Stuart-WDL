version 1.0

task fun_with_optionals {
	input {
		Boolean return_a_file
	}

	command <<<
		if [ "~{return_a_file}" == "true" ]
		then
			touch "1.txt"
			touch "2.txt"
		fi
	>>>

	runtime {
		cpu: 2
		disks: "local-disk 10 HDD"
		docker: "ashedpotatoes/sranwrp:1.1.3"
		memory: "4 GB"
		preemptible: 1
	}

	output {
		File? one_file = "1.txt" # can return None
		Array[File?] manual_optional_file = ["1.txt", "2.txt"]
		Array[File?] glob_optional_file = glob("*.txt") # can never return None

		File? two_file = "2.txt" # can return None
		####Array[File]? manual_optional_array = ["2.txt", "1.txt"] # errors if passed false
		Array[File]? glob_optional_array = glob("*.txt") # can never return None
	}
}

task do_something {
	input {
		Array[File] files
	}
	command <<<
		set -eux pipefail
		diff ~{ sep=' ' files}
	>>>
	runtime {
		cpu: 2
		disks: "local-disk 10 HDD"
		docker: "ashedpotatoes/sranwrp:1.1.3"
		memory: "4 GB"
		preemptible: 1
	}
}


workflow SelectAll {
	input {
		Array[Boolean] magic_eight_ball = [true, false, true]
	}
	
	scatter(bool in magic_eight_ball) {
		call fun_with_optionals {
			input:
				return_a_file = bool
		}
		# Let's try to coerce the outputs into non-optionals within the scatter

		# one_file/two_file: File?
		####File coerced_one_file_in_scatter = select_first([fun_with_optionals.one_file])
		####File coerced_two_file_in_scatter = select_first([fun_with_optionals.two_file])
		# This will pass womtool/miniwdl check, but obviously fails when fun_with_optionals
		# is passed false, because there is no fallback file in this select_first.
		# That makes sense, that isn't really an issue, but some of the proceeding are less intutive...

		# manual_optional_file: Array[File?] created without globbing
		Array[File] coerced_manual_optional_file_in_scatter = select_all(fun_with_optionals.manual_optional_file)

		# glob_optional_file: Array[File?] created by globbing
		Array[File] coerced_glob_optional_file_in_scatter   = select_all(fun_with_optionals.glob_optional_file)

		# manual_optional_array: Array[File]? created without globbing
		####Array[File] coerced_manual_optional_array_in_scatter = select_all(fun_with_optionals.manual_optional_array)
		# Even if manual_optional_array was always valid (ie was always passed true), this coercion isn't valid.

		# glob_optional_array: Array[File]? created by globbing
		####Array[File] coerced_glob_optional_array_in_scatter = select_all(fun_with_optionals.glob_optional_array)

		# We have one other option...
		if(length(fun_with_optionals.glob_optional_file)>1) {
    		Array[File] cool_method = select_all(fun_with_optionals.glob_optional_file)
  		}
	}
	# Now, let's try to coerce the outputs outside the scatter

	# one_file/two_file: Array[File?]
	Array[File] coerced_one_file_out_scatter = select_all(fun_with_optionals.one_file)
	Array[File] coerced_two_file_out_scatter = select_all(fun_with_optionals.two_file)

	# manual_optional_file: Array[Array[File?]] created without globbing
	####Array[Array[File]] coerced_manual_optional_file_out_scatter  = select_all(fun_with_optionals.manual_optional_file)

	# glob_optional_file: Array[Array[File?]] created by globbing
	####Array[Array[File]] coerced_glob_optional_file_out_scatter    = select_all(fun_with_optionals.glob_optional_file)

	# manual_optional_array: Array[File]? created without globbing
	####Array[Array[File]] coerced_manual_optional_array_out_scatter = select_all(fun_with_optionals.manual_optional_array)
	# This would be valid if manual_optional_array were always valid (ie if only ever passed true)!

	# glob_optional_array: Array[Array[File]?] created by globbing
	Array[Array[File]] coerced_glob_optional_array_out_scatter   = select_all(fun_with_optionals.glob_optional_array)


	# So, with all that said and done, you can get Array[Array[File]] from a task with optional outs:
	# 1. Iff you know the filenames of the outputs and the exact number of outputs, you can select_all() from
	#    outside the scatter to create an Array[File], and then merge those to create an Array[Array[File]].
	# 2. Same as #1 but task-level output is Array[File?] instead of merging two File?s.
	# 3. Create Array[File?] via globbing, then inside the scatter, select_all() the resulting Array[File?], which
	#    will become an Array[Array[File]] outside the scatter.
	# 4. Create Array[File]? via globbing, then outside the scatter, select_all() the resulting Array[Array[File]?]
	# 5. The cool but uninutitive method of pairing length() with select_all().

	# But we're not out of the woods yet. Let's try to do something on these arrays.

	# Option 1
	scatter(files in [coerced_one_file_out_scatter, coerced_two_file_out_scatter]) {
		call do_something as diff_1 {
			input:
				files = files
		}
	}

	# Option 2
	####scatter(files in coerced_manual_optional_file_in_scatter) {
	####	call do_something as diff_2 {
	####		input:
	####			files = files
	####	}
	####}
	# Fails on 1st (0,1,2) iteration due to being passed an empty array

	# Option 3
	####scatter(files in coerced_glob_optional_file_in_scatter) {
	####	call do_something as diff_3 {
	####		input:
	####			files = files
	####	}
	####}
	# Fails on 1st (0,1,2) iteration due to being passed an empty array

	# Option 4
	####scatter(files in coerced_glob_optional_array_out_scatter) {
	####	call do_something as diff_4 {
	####		input:
	####			files = files
	####	}
	####}
	# Fails on 1st (0,1,2) iteration due to being passed an empty array

	# Option 5
	scatter(files in cool_method) {
		call do_something as diff_5 {
			input:
				files = select_all(files)
		}
	}
	# Yes, you have to use select_all() twice -- once when declaring cool_method, and again
	# before you can put them into the diff task, even though you already wrapped the creation
	# of cool_method into "only do this is length>1". Basically, you have to wrap it three
	# times over instead of just once.
}