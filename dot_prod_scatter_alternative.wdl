version 1.0

task configure_cross_product {
	input {
		Array[Array[String]] files
		File segments_file
	}

	command <<<
		cat ~{write_json(files)}

		python2<<CODE
		import json
		files = json.load(open("~{write_json(files)}"))
		for file in files:
			print(file)

		IIsegments_fileII = "~{segments_file}"
		IIinput_gds_filesII = files[0]
		IIvariant_include_filesII = files[2]
		IIaggregate_filesII = files[1]

		from zipfile import ZipFile
		import os
		import shutil
		import datetime

		def find_chromosome(file):
			chr_array = []
			chrom_num = split_on_chromosome(file)
			if len(chrom_num) == 1:
				acceptable_chrs = [str(integer) for integer in list(range(1,22))]
				acceptable_chrs.extend(["X","Y","M"])
				if chrom_num in acceptable_chrs:
					return chrom_num
				else:
					print("%s appears to be an invalid chromosome number." % chrom_num)
					exit(1)
			elif (unicode(str(chrom_num[1])).isnumeric()):
				# two digit number
				chr_array.append(chrom_num[0])
				chr_array.append(chrom_num[1])
			else:
				# one digit number or Y/X/M
				chr_array.append(chrom_num[0])
			return "".join(chr_array)

		def split_on_chromosome(file):
			chrom_num = file.split("chr")[1]
			return chrom_num

		def pair_chromosome_gds(file_array):
			gdss = dict() # forced to use constructor due to WDL syntax issues
			for i in range(0, len(file_array)): 
				# Key is chr number, value is associated GDS file
				this_chr = find_chromosome(file_array[i])
				if this_chr == "X":
					gdss[23] = file_array[i]
				elif this_chr == "Y":
					gdss[24] = file_array[i]
				elif this_chr == "M":
					gdss[25] = file_array[i]
				else:
					gdss[int(this_chr)] = file_array[i]
			return gdss

		def pair_chromosome_gds_special(file_array, agg_file):
			gdss = dict()
			for i in range(0, len(file_array)):
				gdss[int(find_chromosome(file_array[i]))] = agg_file
			return gdss

		def wdl_get_segments():
			segfile = open(IIsegments_fileII, 'rb')
			segments = str((segfile.read(64000))).split('\n') # CWL x.contents only gets 64000 bytes
			segfile.close()
			segments = segments[1:] # remove first line
			return segments

		######################
		# prepare GDS output #
		######################
		input_gdss = pair_chromosome_gds(IIinput_gds_filesII)
		output_gdss = []
		gds_segments = wdl_get_segments()
		for i in range(0, len(gds_segments)): # for(var i=0;i<segments.length;i++){
			try:
				chr = int(gds_segments[i].split('\t')[0])
			except ValueError: # chr X, Y, M
				chr = gds_segments[i].split('\t')[0]
			if(chr in input_gdss):
				output_gdss.append(input_gdss[chr])
		gds_output_hack = open("gds_output_debug.txt", "w")
		gds_output_hack.writelines(["%s " % thing for thing in output_gdss])
		gds_output_hack.close()

		######################
		# prepare seg output #
		######################
		input_gdss = pair_chromosome_gds(IIinput_gds_filesII)
		output_segments = []
		actual_segments = wdl_get_segments()
		for i in range(0, len(actual_segments)): # for(var i=0;i<segments.length;i++){
			try:
				chr = int(actual_segments[i].split('\t')[0])
			except ValueError: # chr X, Y, M
				chr = actual_segments[i].split('\t')[0]
			if(chr in input_gdss):
				seg_num = i+1
				output_segments.append(seg_num)
				output_seg_as_file = open("%s.integer" % seg_num, "w")

		# I don't know for sure if this case is actually problematic, but I suspect it will be.
		if max(output_segments) != len(output_segments):
			print("ERROR: output_segments needs to be a list of consecutive integers.")
			print("Debug: Max of list: %s. Len of list: %s." % 
				[max(output_segments), len(output_segments)])
			print("Debug: List is as follows:\n\t%s" % output_segments)
			exit(1)

		segs_output_hack = open("segs_output_debug.txt", "w")
		segs_output_hack.writelines(["%s " % thing for thing in output_segments])
		segs_output_hack.close()

		######################
		# prepare agg output #
		######################
		# The CWL accounts for there being no aggregate files as the CWL considers them an optional
		# input. We don't need to account for that because the way WDL works means it they are a
		# required output of a previous task and a required input of this task. That said, if this
		# code is reused for other WDLs, it may need some adjustments right around here.
		input_gdss = pair_chromosome_gds(IIinput_gds_filesII)
		agg_segments = wdl_get_segments()
		if 'chr' in os.path.basename(IIaggregate_filesII[0]):
			input_aggregate_files = pair_chromosome_gds(IIaggregate_filesII)
		else:
			input_aggregate_files = pair_chromosome_gds_special(IIinput_gds_filesII, IIaggregate_filesII[0])
		output_aggregate_files = []
		for i in range(0, len(agg_segments)): # for(var i=0;i<segments.length;i++){
			try: 
				chr = int(agg_segments[i].split('\t')[0])
			except ValueError: # chr X, Y, M
				chr = agg_segments[i].split('\t')[0]
			if(chr in input_aggregate_files):
				output_aggregate_files.append(input_aggregate_files[chr])
			elif (chr in input_gdss):
				output_aggregate_files.append(None)

		#########################
		# prepare varinc output #
		#########################
		input_gdss = pair_chromosome_gds(IIinput_gds_filesII)
		var_segments = wdl_get_segments()
		if IIvariant_include_filesII != [""]:
			input_variant_files = pair_chromosome_gds(IIvariant_include_filesII)
			output_variant_files = []
			for i in range(0, len(var_segments)):
				try:
					chr = int(var_segments[i].split('\t')[0])
				except ValueError: # chr X, Y, M
					chr = var_segments[i].split('\t')[0]
				if(chr in input_variant_files):
					output_variant_files.append(input_variant_files[chr])
				elif(chr in input_gdss):
					output_variant_files.append(None)
				else:
					pass
		else:
			null_outputs = []
			for i in range(0, len(var_segments)):
				try:
					chr = int(var_segments[i].split('\t')[0])
				except ValueError: # chr X, Y, M
					chr = var_segments[i].split('\t')[0]
				if(chr in input_gdss):
					null_outputs.append(None)
			output_variant_files = null_outputs
		var_output_hack = open("variant_output_debug.txt", "w")
		var_output_hack.writelines(["%s " % thing for thing in output_variant_files])
		var_output_hack.close()

		# make a bunch of arrays
		print("Preparing dot-product arrays...")
		everything = []
		for i in range(0, max(output_segments)):
			plusone = i+1
			# leaving out output_segments[i] for now
			this_dot_prod = [output_gdss[i], output_aggregate_files[i]]
			if IIvariant_include_filesII != [""]:
				print("Info: We detected %s as an output variant file." % output_variant_files[i])
				this_dot_prod.append(output_variant_files[i])
			print("Info: Made segment %s array" % plusone)
			everything.append(this_dot_prod)
		print("Debug: Array of arrays is as follows: %s" % everything)
		arraylist = []
		arraylist.append('[')
		for array in everything:
			arraylist.append('["')
			arraylist.append('","'.join([str(file) for file in array]))
			arraylist.append('"]')
			arraylist.append(",")
		arraylist = arraylist[:-1]
		arraylist.append(']')
		print("".join(arraylist))
		f = open("output_files.json", "w")
		f.write("".join(arraylist))
		f.close()

		CODE
	>>>

	output {
		Array[Array[String]] crossed = read_json("output_files.json")
	}
}

task take_in_dot_prods {
	input {
		File a
		File b
		File c
	}

	command {
		echo "~{a}"
		echo "~{b}"
		echo "~{c}"
	}
}

workflow dot_product_scatter_alternative {
	input {
		Array[File] files_a
		Array[File] files_b
		Array[File] files_c
		File segments_file
	}
	call configure_cross_product {
		input: files = [files_a,files_b,files_c], segments_file = segments_file
	}
	scatter(product in configure_cross_product.crossed){
		call take_in_dot_prods {
			input:
				a = product[0],
				b = product[1],
				c = product[2]
		}
	}
}