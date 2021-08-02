version 1.0

# Big Cheese
#
# This task demonstrates how to calculate disk size based upon inputs. It
# also includes an optional input for a user to increase disk size further.
# This is an important thing to have for any workflows running on a Google-
# based backend, including Terra, because Google-based backends do not
# autoscale. On Terra specifically, if you do not specify a `disks` runtime
# attribute, Google will shut you down once you reach about 10 GB of disk
# space. If you do specify a `disks` size but go over it, you will also be
# shut down. Storage tends to be relatively cheap, but the cost of rerunning
# a workflow should Google shut it down is not trivial, so always err on the
# side of overestimating what you need. It is also good practice to allow the
# user to tack on a few extra gigs -- they may be running on huge files that
# generate intermediate files larger than what you anticipated!

task stuart_bigcheese {

	input {
		File some_file
		Array[File] some_group_of_files

		# If the user does not specify this input, it is set to 1
		# If the user specifies a float, the workflow will fail.
		# An alternative would be to make this a float, and then
		# in the section below, use ceil() to coerce the float into
		# an integer.
		Int? addl_disk = 1
	}

	# These variables are outside the input section, but also outside the
	# task section. They basically function like private variables -- the
	# command and runtime sections of this task can access them, but users
	# cannot set them and they do not show in Terra's workflow input UI.
	# Note that ceil() rounds up, so all inputs will give a min of 1 GB.
	Int single_file_input_size = ceil(size(some_file, "GB"))
	Int array_of_files_input_size = ceil(size(some_group_of_files, "GB"))
	Int total_disk_size = single_file_input_size + array_of_files_input_size + addl_disk

	command <<<

	echo "Single file input is roughly ~{single_file_input_size} GB."
	echo "Array of files input is roughly ~{array_of_files_input_size} GB."
	echo "The addl_disk variable is set to ~{addl_disk} GB."
	echo "In total, we are requesting ~{total_disk_size} GB."

	echo "How is this interpreted on different backends?"
	echo "If we are running locally, the disk size is ignored."
	echo "If we are running on AWS, the disk size is ignored."
	echo "If we are running on Google/Terra, ~{total_disk_size} GB is treated as a hard limit."

	>>>

	runtime {
		cpu: 2
		docker: "quay.io/aofarrel/rchecker:1.1.0"
		memory: "2 GB"
		preemptible: 2

		# The `disks` runtime argument is somewhat unique. It is not written
		# as just an integer like `cpu` or `preemptible` but rather as a string
		# with a very specific triplet format.
		# https://cromwell.readthedocs.io/en/stable/RuntimeAttributes/#disks
		# The number put in your disks string MUST be an integer, not a float!
		disks: "local-disk " + total_disk_size + " HDD"
	}
}