library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_GEN is
Generic (NBIT: integer:= 16);
Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
       	B:	In	std_logic_vector(NBIT-1 downto 0);
       	SEL:	In	std_logic;
       	Y:	Out	std_logic_vector(NBIT-1 downto 0));
end MUX21_GEN;

architecture BEHAVIORAL of MUX21_GEN is
  begin
    
    Y <= A when SEL='1' else B;
    
end BEHAVIORAL;

