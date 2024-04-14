# Modified DLX Architecture

## Project Overview
During this project, we developed and implemented the Integer Unit of the DLX architecture, incorporating several significant enhancements. These improvements include an extended instruction set, a hardwired control unit, an advanced datapath, and a highly efficient multiplication unit. The upgraded Integer Unit is designed with advanced capabilities such as data forwarding, hazard detection, and stall management to optimize overall system performance. The development process involved detailed simulations, synthesis, and place & route, culminating in the final layout of the component.

## Getting Started

### Prerequisites
Ensure you have all necessary tools and dependencies installed that are required to run the simulations and synthesizing tools used in this project. This might include a specific software or environment setup detailed in a separate documentation file if needed. For the simulation phase it is necessary to use Mentor QuestaSim while for the synthesis part, Synopsys Design Compiler is needed.

### Running Simulations
To start a simulation, execute the following steps:

1. **Prepare your assembly file**: Ensure that your assembly file (`yourfile.asm`) is saved in the "sim" folder.

2. **Run the Assembler script**: In the project's root directory, run the `Assembler.sh` script followed by the name of the assembly file you wish to simulate. Use the command below:
   ```bash
   ./Assembler.sh yourfile.asm

3. **View the results**: After running the script, check the output and logs to verify the simulation results.

## Additional Information
For more detailed information about the project structure, enhancements, and other technical details, refer to the supplementary docs provided in the `docs` folder.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Authors
- Your Name

## Acknowledgments
- Acknowledge any contributors or sources of inspiration.