# ##########################################################
# 
# Title			: project_cleaner.tcl
# Author 		: O.C.
# Description	: Deletes some unwanted files:
#					-vivado_*.jou
#					-vivado_*.backup*
#					-hs_err_pid*
#					-ps_clock_registers*
#					-.hdi.isWriteableTest*
# 
# ########################################################### 

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

#Setting the current directory
set origin_dir [file dirname [info script]]

#Creating a list of all the undesirable files
set undesirable_files [list \
{*}[findFiles $origin_dir "vivado_*.jou"]\
{*}[findFiles $origin_dir "vivado_*.backup*"]\
{*}[findFiles $origin_dir "hs_err_pid*"]\
{*}[findFiles $origin_dir "ps_clock_registers*"]\
{*}[findFiles $origin_dir ".hdi.isWriteableTest*"]
]

#Deleting the aforementioned files
foreach file $undesirable_files {
file delete $file
}



 