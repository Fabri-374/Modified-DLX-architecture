library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PG is
	port (
		Pik :	in	std_logic;
		Gik :	in	std_logic;
		Pkj :	in	std_logic;
		Gkj :	in	std_logic;
		Pij :	out	std_logic;
		Gij :	out	std_logic);
end PG;

architecture BEHAVIORAL of PG is

begin

Pij <= Pik AND Pkj;
Gij <= Gik OR (Pik AND Gkj);


end BEHAVIORAL;
