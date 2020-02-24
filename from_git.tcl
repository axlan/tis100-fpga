# ##########################################################
# 
# Title			: from_git.tcl
# Author 		: O.C.
# Description	: Takes the tcl scripts and recreates the 
# 				  project
# 
# ##########################################################

#Setting the directory where the <to_git.tcl> file resides
set origin_dir [file dirname [info script]]

#Running the build.tcl script
source $origin_dir/build.tcl

#Cleans the project from the undesired files (like journals)
source project_cleaner.tcl

#Exiting the cmd window
exit

