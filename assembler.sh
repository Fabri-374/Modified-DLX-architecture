#########################################################
#							#
#	Script to automate assembler operations 	#
#							#
#########################################################
#!/bin/bash

echo "Moving to the Simulation folder..."
cd sim


if [ ! -r $1 ]
then
	echo "Usage: $0 <dlx_assembly_file>.asm"
	exit 1
fi

asmfile=`echo $1 | sed s/[.].*//g`

# Check if the file exists at the specified path
if [ -e "$asmfile" ]; then
	rm test.asm.mem
	rm test.list
fi

cd Scripts
cp ../$asmfile.asm .
echo "Creating the necessary asm.mem file..."
perl dlxasm.pl -o $asmfile.asm.exe -list test.list $1
rm $asmfile.asm.exe.hdr
sh conv2memory.sh $asmfile.asm.exe > test.asm.mem
rm $asmfile.asm.exe
rm $asmfile.asm
cd ..
mv Scripts/test.asm.mem .
mv Scripts/test.list .
# comment the following lines if you don't want to start the simulation
cd ..
echo "launching simulation..."
source Simulation.sh
