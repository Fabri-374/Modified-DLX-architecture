library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PG_network is
	generic (Nbits : integer :=32);
	port (
		A : in std_logic_vector(Nbits-1 downto 0);
		B : in std_logic_vector(Nbits-1 downto 0);
		Cin : in std_logic; 
		P : out std_logic_vector(Nbits-1 downto 0);
		G : out std_logic_vector(Nbits-1 downto 0));
end PG_network;

architecture BEHAVIORAL of PG_network is

begin

process(A,B,Cin)
begin
	Pg: for i in 0 to (Nbits-1) loop
		if (i=0) then       --if it is the first PG block, we have to take into account the carry in
			P(i) <= A(i) XOR B(i);
			G(i) <= (A(i) AND B(i)) OR (A(i) AND Cin) OR (B(i) AND Cin);
		else 
			P(i) <= A(i) XOR B(i);
			G(i) <= A(i) AND B(i);
		end if;
	end loop Pg;
end process;

end BEHAVIORAL;
