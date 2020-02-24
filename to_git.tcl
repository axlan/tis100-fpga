# ##########################################################
# 
# Title			: to_git.tcl
# Author 		: O.C.
# Description	: Reduces the project to a few tcl scripts
#				  practical for version controlled
# 
# ##########################################################

#Setting the directory where the <to_git.tcl> file resides
set origin_dir [file dirname [info script]]
set block_origin_dir $origin_dir/src/bd

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
 
#Looking for project name
set project_name [file rootname [file tail [findFiles $origin_dir "*.xpr"]]]
 
#Opening the project
puts $origin_dir/tis100/$project_name.xpr
open_project $origin_dir/tis100/$project_name.xpr

#Creating the block designs from the tcl scripts
source $origin_dir/src/bd/block_design_tcl.tcl

#Creating a tcl file that represents the project
write_project_tcl -force build.tcl

#Cleans the project (shouldn't be necessary though)
source project_cleaner.tcl

#Exiting cmd prompt
exit