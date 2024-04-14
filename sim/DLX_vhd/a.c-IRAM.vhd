library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.constants.all;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file

-- Define the IRAM entity with generic and port declarations
entity IRAM is
	generic (
	  RAM_DEPTH : integer := RAM_DEPTH;  -- Depth of the IRAM
	  I_SIZE : integer := I_SIZE       -- Size of each instruction
	);
	port (
	  Rst  : in  std_logic;                         -- Reset signal
	  Addr : in  std_logic_vector(I_SIZE - 1 downto 0);  -- Address input
	  Dout : out std_logic_vector(I_SIZE - 1 downto 0)  -- Data output
	);
  end IRAM;
  
-- Define the behavioral architecture for the IRAM entity
architecture behavioral of IRAM is

	-- Define a memory type as an array of bytes
	type MEM_type is array (0 to RAM_DEPTH - 1) of byte;
	signal MEM: MEM_type;        
	signal Addr_to_int: natural;   -- Signal to convert address to integer
	signal end_file : integer;     -- Signal to track the end of the file
	signal byte0_out, byte1_out, byte2_out, byte3_out: byte;  -- Output bytes
  
begin
	-- Convert the address input to an integer
	Addr_to_int <= to_integer(unsigned(Addr(30 downto 0)));
  
	-- Select bytes from memory based on the address input
	byte0_out <= MEM(Addr_to_int) when Addr_to_int <= end_file - 1 else (others => 'Z');
	byte1_out <= MEM(Addr_to_int + 1) when Addr_to_int + 1 <= end_file - 1 else (others => 'Z');
	byte2_out <= MEM(Addr_to_int + 2) when Addr_to_int + 2 <= end_file - 1 else (others => 'Z');
	byte3_out <= MEM(Addr_to_int + 3) when Addr_to_int + 3 <= end_file - 1 else (others => 'Z');
  
	-- Concatenate the selected bytes to form the data output
	Dout <= byte3_out & byte2_out & byte1_out & byte0_out;
  
	-- This process is responsible for filling the Instruction RAM with firmware
	FILL_IRAM : process(Rst)
	  file mem_fp: text;
	  variable file_line : line;
	  variable n_byte : integer := 0;
	  variable instruction : std_logic_vector(I_SIZE - 1 downto 0);
	begin
	  if (Rst = '0') then 
		-- Open the memory file for reading
		file_open(mem_fp, "test.asm.mem", READ_MODE);
		while (not endfile(mem_fp)) loop
		  readline(mem_fp, file_line);
		  hread(file_line, instruction);
  
		  -- Store the instruction in memory bytes
		  MEM(n_byte) <= instruction(byte_range);
		  MEM(n_byte + 1) <= instruction(byte1_range);
		  MEM(n_byte + 2) <= instruction(byte2_range);
		  MEM(n_byte + 3) <= instruction(byte3_range);
  
		  n_byte := n_byte + 4;
		end loop;
	  end if;
	  end_file <= n_byte - 4;  -- Track the end of the file
	end process FILL_IRAM;

end behavioral;
