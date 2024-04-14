#########################################################
#							#
#	Script to automate operations in synthesis	#
#							#
#########################################################
#!/bin/bash

echo "Moving to the Synthesis folder..."
cd syn

# Specify the path of the file to check
file_to_check=".synopsys_dc.setup"

# Specify the destination folder where to import the file if it doesn't exist
source_folder="/home/repository/ms/setup/"

# Check if the file exists at the specified path
if [ -e "$file_to_check" ]; then
    echo "The file $file_to_check already exists at the specified path."
else
    
    # Copy the file to the destination folder
    cp "$source_folder""$file_to_check" .
    
    # Check if the copy was successful
    if [ $? -eq 0 ]; then
        echo "The file has been successfully copied to the Synthesis folder."
    else
        echo "An error occurred while copying the file."
    fi
fi

echo "Starting Synopsys setup..."
setsynopsys

echo "Starting Design Vision without graphical interface using the synthesis.tcl script..."
design_vision -f Synthesis.tcl -no_gui

#remove the exit command in Synthesis.tcl if the gui is used

#echo "Starting Design Vision with graphical interface using the synthesis.tcl script..."
#design_vision -f Synthesis.tcl -gui
