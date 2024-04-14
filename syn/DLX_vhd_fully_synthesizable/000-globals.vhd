library ieee;
use ieee.std_logic_1164.all;

package CONSTANTS is
   constant NumBit : integer := 32;	
   constant NBIT : integer := 32;
   constant I_SIZE : integer := 32;
 constant OPCODE_SIZE : integer := 6;
constant ADD_RF_LENGTH : integer := 5;
   constant Addr_Length : integer := 5;
	constant RAM_DEPTH : integer := 5000; -- # RIGHE FILE_TEST *4 (o lasciare più grande)

   -- constants for sign extend --
   constant IMMEDIATE_LENGTH : integer := 16;
   constant BRANCHLABEL_LENGTH : integer := 26;

   -- constants for execution unit --
   constant NBIT_PER_BLOCK : integer := 4;

   constant WORD_SIZE : integer := 32; 
   constant DRAM_SIZE : integer := 1024;

	constant BYTE_SIZE : integer := 8;
	subtype BYTE_range is integer range BYTE_SIZE-1 downto 0;
	subtype BYTE1_range is integer range 2*BYTE_SIZE-1 downto BYTE_SIZE;
	subtype BYTE2_range is integer range 3*BYTE_SIZE-1 downto 2*BYTE_SIZE;
	subtype BYTE3_range is integer range 4*BYTE_SIZE-1 downto 3*BYTE_SIZE;
	subtype byte is std_logic_vector(BYTE_range);

end CONSTANTS;

library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  6;                                             -- FUNC field size
    constant MICROCODE_MEM_SIZE :     integer := 62;  -- Microcode Memory Size
    constant I_SIZE            :     integer := 32;
    constant CW_SIZE            :     integer := 27;  -- Control Word Size

-- R-Type instruction -> FUNC field
    constant TYPE_ADD : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  	"100000";  
    constant TYPE_SUB : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  	"100010";   
    constant TYPE_AND : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"100100";
    constant TYPE_OR : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"100101";
    constant TYPE_XOR : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"100110";
    constant TYPE_SGE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101101";
    constant TYPE_SLE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101100";
    constant TYPE_SLL : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"000100";
    constant TYPE_SNE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101001";
    constant TYPE_SRL : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"000110";
    constant TYPE_SRA : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"000111";
    constant TYPE_SEQ : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101000";
    constant TYPE_SGT : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101011";
    constant TYPE_SLT : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"101010";
    constant TYPE_SLTU : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"111010";
    constant TYPE_SGTU : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"111011";
    constant TYPE_SLEU : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"111100";
    constant TYPE_SGEU : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"111101";
    constant TYPE_NOP : std_logic_vector(OP_CODE_SIZE-1 downto 0) := 	"000000";
    constant TYPE_MOV : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  	"101111"; 
    constant TYPE_MOVI : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  	"110011"; 

end myTypes;

package functions is

	--Calculates the division between the two parameters, the result is an integer which is rounded by excess
	
	function divide (n:integer; m:integer) return integer;

	-- Calculates the log in base 2 of the number n, the result is an integer which is rounded by excess

	function log2 (n:integer) return integer;

end functions;

library ieee;
use ieee.std_logic_1164.all;

package body functions is

	function divide (n:integer; m:integer) return integer is
	begin

		if (n mod m) = 0 then

			return n/m;
		else

			return (n/m) + 1;
		end if;
	
	end divide;
	
	function log2 (n:integer) return integer is
	
	begin
		if n <=2 then
	
			return 1;
		else
	
			return 1 + log2(divide(n,2));
		end if;
	end log2;
end functions;

