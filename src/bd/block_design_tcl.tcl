# ##########################################################
# 
# Title			: block_design_tcl.tcl
# Author 		: O.C.
# Description	: Generates tcl scripts for every bd design
#				  within the IP_repo in the project
# 
# ##########################################################


# Function that recursively looks through directories -> https://stackoverflow.com/questions/429386/tcl-recursively-search-subdirectories-to-source-all-tcl-files
	# findFiles
	# basedir - the directory to start looking in
	# pattern - A pattern, as defined by the glob command, that the files must match
	proc findFiles { basedir pattern } {

		# Fix the directory name, this ensures the directory name is in the
		# native format for the platform and contains a final directory seperator
		set basedir [string trimright [file join [file normalize $basedir] { }]]
		set fileList {}

		# Look in the current directory for matching files, -type {f r}
		# means ony readable normal files are looked at, -nocomplain stops
		# an error being thrown if the returned list is empty
		foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
			lappend fileList $fileName
		}

		# Now look for any sub direcories in the current directory
		foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
			# Recusively call the routine on the sub directory and append any
			# new files to the results
			set subDirList [findFiles $dirName $pattern]
			if { [llength $subDirList] > 0 } {
				foreach subDirFile $subDirList {
					lappend fileList $subDirFile
				}
			}
		}
		return $fileList
	 }
	#End of function 
 
#Creating a list of all .bd files 
set tcl_files [findFiles $origin_dir "*.bd"]
 
#Setting the name of this file, without extension (rootname) nor path (tail)
set current_file [file rootname [file tail [info script]]]

#Doing this procedure for every block design in the folder
foreach tcl_file $tcl_files {

	#Getting the name of the current design (no extension and no path)
	set bd_name [file rootname [file tail $tcl_file]]
	
	#Opening the block diagram
	open_bd_design $origin_dir/IP_repo/$bd_name/$bd_name.bd

	#Writing the tcl script in the right directory
	cd $block_origin_dir
	write_bd_tcl -force -bd_name $bd_name -bd_folder $block_origin_dir $bd_name
	close_bd_design  $bd_name
	
	#Returning to the $origin_dir directory
	cd ../..
}




