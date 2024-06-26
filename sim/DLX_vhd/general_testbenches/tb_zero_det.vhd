library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.constants.all; 

entity tb is
end tb;

architecture test of tb is

component ZERO_DETECTOR is
	generic (	N: integer := NumBit);								--THIS TESTBENCH WAS MADE ON N = 8 bits, for simplicity
	Port (	A:	In	std_logic_vector(N-1 DOWNTO 0);
		Y:	Out	std_logic);
end component;

constant NBIT: integer:=8;
signal a_S: std_logic_vector(NBIT-1 downto 0);
signal result: std_logic;

begin

	UUT: ZERO_DETECTOR generic map (N=>NBIT) port map (a_S,result);

	process
	begin
		a_S<="00000001";
		wait for 5 ns;
		a_S<="00000000";
		wait for 5 ns;
		a_S<="00001001";
		wait for 5 ns;
		a_S<="00000001";
		wait for 5 ns;
		a_S<="01000001";
		wait for 5 ns;
		a_S<="01001001";
		wait for 5 ns;
		a_S<="10101010";
		wait;
	end process;
end test;
