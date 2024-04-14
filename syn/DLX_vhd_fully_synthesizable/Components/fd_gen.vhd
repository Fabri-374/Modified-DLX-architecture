library IEEE;
use IEEE.std_logic_1164.all; 

entity FD_GEN is
Generic (NBIT: integer:= 16);
	Port (	D:	In	std_logic_vector(NBIT-1 downto 0);
		CK:	In	std_logic;
		EN: 	In std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(NBIT-1 downto 0));
end FD_GEN;


architecture SYNC of FD_GEN is -- flip flop D with syncronous reset

begin
	PSYNCH: process(CK)
	begin
	  if CK'event and CK='1' then -- positive edge triggered:
	    if RESET='1' then -- active high reset 
	      Q <= (others => '0'); 
	    else
		  if EN = '1' then
	      Q <= D; -- input is written on output
		  end if;
	    end if;
	  end if;
	end process;

end SYNC;


