library ieee;
use ieee.std_logic_1164.all;

-- Define a package named CONSTANTS
package CONSTANTS is
   constant NumBit : integer := 32;	    -- Number of bits for various data types
   constant NBIT : integer := 32;	    -- Same as NumBit, indicating a 32-bit value
   constant I_SIZE : integer := 32;	    -- Instruction size 
   constant OPCODE_SIZE : integer := 6;	    -- Size of the opcode field in instructions
   constant ADD_RF_LENGTH : integer := 5;  -- Length of the register file address
   constant Addr_Length : integer := 5;    -- Length of address fields
   constant RAM_DEPTH : integer := 5000;   -- Depth of a RAM module

   -- Constants for sign extension
   constant IMMEDIATE_LENGTH : integer := 16;      -- Length of immediate values
   constant BRANCHLABEL_LENGTH : integer := 26;     -- Length of branch labels

   -- Constants for the execution unit
   constant NBIT_PER_BLOCK : integer := 4;         -- Number of bits per block
   constant WORD_SIZE : integer := 32;             -- Word size
   constant DRAM_SIZE : integer := 1024;           -- Size of DRAM memory

   constant BYTE_SIZE : integer := 8;              -- Size of a byte
   subtype BYTE_range is integer range BYTE_SIZE-1 downto 0;    -- Subtype for the first byte
   subtype BYTE1_range is integer range 2*BYTE_SIZE-1 downto BYTE_SIZE;  -- Subtype for the second byte
   subtype BYTE2_range is integer range 3*BYTE_SIZE-1 downto 2*BYTE_SIZE;  -- Subtype for the third byte
   subtype BYTE3_range is integer range 4*BYTE_SIZE-1 downto 3*BYTE_SIZE;  -- Subtype for the fourth byte
   subtype byte is std_logic_vector(BYTE_range);   -- Subtype for a byte

end CONSTANTS;

library ieee;
use ieee.std_logic_1164.all;

-- Define a package named functions
package functions is

   -- Function to calculate division with rounding up
   function divide (n:integer; m:integer) return integer;

   -- Function to calculate the base-2 logarithm with rounding up
   function log2 (n:integer) return integer;

end functions;

library ieee;
use ieee.std_logic_1164.all;

-- Define the body of the functions package
package body functions is

   -- Implementation of the divide function
   function divide (n:integer; m:integer) return integer is
   begin
      if (n mod m) = 0 then
         return n/m;
      else
         return (n/m) + 1;
      end if;
   end divide;
   
   -- Implementation of the log2 function
   function log2 (n:integer) return integer is
   begin
      if n <= 2 then
         return 1;
      else
         return 1 + log2(divide(n, 2));
      end if;
   end log2;

end functions;

library ieee;
use ieee.std_logic_1164.all;

-- Define a package named myTypes
package myTypes is

   -- Control unit input sizes
   constant OP_CODE_SIZE : integer :=  6;            -- Size of the OPCODE field
   constant FUNC_SIZE : integer :=  6;               -- Size of the FUNC field
   constant MICROCODE_MEM_SIZE : integer := 62;      -- Size of Microcode Memory
   constant I_SIZE : integer := 32;                 -- Size of instructions
   constant CW_SIZE : integer := 27;                -- Size of Control Words

   -- Definitions for R-Type instructions and their associated FUNC values
   constant TYPE_ADD : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  "100000";  -- ADD instruction
   constant TYPE_SUB : std_logic_vector(OP_CODE_SIZE-1 downto 0) :=  "100010";  -- SUB instruction   
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

   -- Definition of a memory array
   type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  	signal cw : mem_array := (
   "100111111010000000101001110", -- R-TYPE
   "000000000000000000000000000", -- 
   "111100001100000000001000000", -- J
   "111100001110000000111000010", -- JAL
   "101110001100000000001101010", -- BEQZ
   "101110001100000000001101010", -- BNEZ     
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "101110101010000000101000110", -- ADDI
   "100110101010000000101000110", -- ADDUI 
   "101110101010000000101000110", -- SUBI		
   "100110101010000000101000110", -- SUBUI 
   "100110101010000000101000110", -- ANDI
   "100110101010000000101000110", -- ORI
   "100110101010000000101000110", -- XORI
   "101100001010000000101000011", -- LHI  
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "100110101000000000001000110", -- JR 
   "100110101010000000111000110", -- JALR 
   "100110101010000000101000110", -- SLLI	
   "100100001010000000001000000", -- NOP
   "100110101010000000101000110", -- SRLI
   "100110101010000000101000110", -- SRAI 
   "101110101010000000101000110", -- SEQI 
   "101110101010000000101000110", -- SNEI
   "101110101010000000101000110", -- SLTI 
   "101110101010000000101000110", -- SGTI 
   "101110101010000000101000110", -- SLEI
   "101110101010000000101000110", -- SGEI
   "000000000000000000000000000", --			
   "000000000000000000000000000", --
   "101111101010011011101010110", -- LB 		
   "101111101010101011101010110", -- LH 
   "000000000000000000000000000", --
   "101111101010001011101010110", -- LW
   "101111101010111011101010110", -- LBU 
   "101111101011001011101010110", -- LHU 
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "101111101010010110001001110", -- SB 
   "101111101010100110001001110", -- SH
   "000000000000000000000000000", --	
   "101111101010000110001001110", -- SW
   "000000000000000000000000000", --				
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "101110101010000000101000110", -- MULTI			
   "100110101010000000101000110", -- MOVI			
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "000000000000000000000000000", --
   "100110101010000000101000110", -- SLTUI 
   "100110101010000000101000110", -- SGTUI 
   "100110101010000000101000110", -- SLEUI 
   "100110101010000000101000110"  -- SGEUI 
	);

end myTypes;

