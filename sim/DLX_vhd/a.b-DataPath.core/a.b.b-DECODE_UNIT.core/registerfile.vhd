library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;
use WORK.constants.all;
use WORK.all;

entity register_file is
generic(NBIT : integer := NumBit;
	ADDR : integer := Addr_Length);
 port (
	RESET: 	IN std_logic;
	ENABLE: 	IN std_logic;
	RD1: 		IN std_logic;
	RD2: 		IN std_logic;
	WR: 		IN std_logic;
	ADD_WR: 	IN std_logic_vector(ADDR-1 downto 0);
	ADD_RD1: 	IN std_logic_vector(ADDR-1 downto 0);
	ADD_RD2: 	IN std_logic_vector(ADDR-1 downto 0);
	DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
	OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
	OUT2: 		OUT std_logic_vector(NBIT-1 downto 0)
);
end register_file;

architecture BEHAVIORAL of register_file is

	-- suggested structures
	subtype REG_ADDR is natural range 0 to (2**ADDR)-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0); 
	signal REGISTERS : REG_ARRAY; 
	signal r0_reg : std_logic_vector(ADDR-1 downto 0) := (others => '0');
	
begin 

-- we divide the behavior of the RF into three different processes: two for the two read ports and the last for the write port --
-- in order to have a cleaner code  --

READ1: process(ENABLE, RD1, ADD_RD1, REGISTERS)
begin
		if (RESET = '1') then
			OUT1 <= (others => '0'); 
		elsif (ENABLE = '1' and RD1 = '1') then
			OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
		else 
			OUT1 <= (others => '0'); 
		end if;
end process READ1;

READ2: process(ENABLE, RD2, ADD_RD2, REGISTERS)
begin
		if (RESET = '1') then
			OUT2 <= (others => '0'); 
		elsif (ENABLE = '1' and RD2 = '1') then
			OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
		else 
			OUT2 <= (others => '0'); 
		end if;
end process READ2;

WRITEPORT: process(RESET, ENABLE, WR, DATAIN, ADD_WR)
begin
		if (RESET = '1') then 
			REGISTERS <= (others => (others => '0')); -- write zeros in all the cells if the reset is active --
		 elsif (ENABLE = '1' and WR = '1') then
			if(ADD_WR /= r0_reg) then
				REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; 
			end if;
		end if;
end process WRITEPORT;

end BEHAVIORAL;