library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity G is
	port (
		Pik :	in	std_logic;
		Gik :	in	std_logic;
		Gkj :	in	std_logic;
		Gij :	out	std_logic);
end G;

architecture BEHAVIORAL of G is
begin

Gij <= Gik OR (Pik AND Gkj);

end BEHAVIORAL;
