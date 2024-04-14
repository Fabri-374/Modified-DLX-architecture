library IEEE;
use IEEE.std_logic_1164.all; 

entity AND2 is
	Port (	A:	In	std_logic;
		B:	In	std_logic;
		Y:	Out	std_logic);
end AND2;


architecture behavioral of AND2 is
begin
	Y <= A and B;
end behavioral;
