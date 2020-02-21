REM ##########################################################
REM
REM Title		: from_git.bat
REM Author 		: O.C.
REM Description	: Deletes a few directories to avoid errors
REM				  and calls the from_git.tcl function
REM 
REM ##########################################################

REM Removing those directories from the project
rmdir /s /q %~dp0\IP_repo
rmdir /s /q %~dp0\work_dir
rmdir /s /q %~dp0\.Xil

REM Making a new IP_repo directory
mkdir %~dp0\IP_repo

REM Applies some changes to the tcl file created previously
REM Important to change directory otherwise the python script doesn't
REM know the proper directory and it thinks the file running is the 
REM <from_git.tcl> file
cd src/bd
python bd_script_changer.py
cd ../..


REM Calling the <from_git.tcl>
vivado -mode tcl -source %~dp0\from_git.tcl
