#########################################################
#							#
#	Script to automate operations in simulation	#
#							#
#########################################################
#!/bin/bash

echo "Moving to the Simulation folder..."
cd sim
cp Scripts/Simulation.tcl .
cp Scripts/Simulation.do .
echo "Starting QuestaSim..."
if [ -e "work" ]; then
	echo "Removing previous simulation files to avoid conflicts..."
	rm -r work
	rm transcript
	rm vsim.wlf
fi
setmentor
echo "Starting the Simulation.tcl script..."
source Simulation.tcl
rm Simulation.tcl Simulation.do
if [ -e "work" ]; then
	echo "Removing useless files..."
	rm -r work
	rm transcript
	rm vsim.wlf
fi
