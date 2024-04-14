library IEEE;
use IEEE.std_logic_1164.all; 

entity XNOR2 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Y:	Out	std_logic);
end XNOR2;


architecture behavioral of XNOR2 is
begin
	Y <= not(A xor B);
end behavioral;