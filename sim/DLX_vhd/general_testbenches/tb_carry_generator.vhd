library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_CARRY_GENERATOR is 
end TB_CARRY_GENERATOR; 

architecture TEST of TB_CARRY_GENERATOR is

	component CARRY_GENERATOR is
		generic (
			NBIT :		integer := 32;
			NBIT_PER_BLOCK: integer := 4);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			Co :	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0));
	end component;
constant NBIT : integer := 32;
constant NBIT_PER_BLOCK : integer := 4;
signal A, B : std_logic_vector(NBIT-1 downto 0);
signal Cin : std_logic;
Signal Co : std_logic_vector(NBIT/NBIT_PER_BLOCK -1 downto 0);

begin

-- we tested some critical cases used also in the ex2.1.2 -- 

A <= "00011111000111110001111100011111", x"FFFFFFFF" after 10 ns, x"F10E8247" after 20 ns, x"FFFFFFFF" after 30 ns, x"00000000" after 40 ns, x"FFFFFFFF" after 50 ns;
B <= "11111000111110001111100011111000", x"00000001" after 10 ns, x"FFF26342" after 20 ns, x"00010000" after 30 ns, x"00000000" after 40 ns;
Cin <= '0',  '1' after 50 ns;

CARRY_GEN_TEST : CARRY_GENERATOR generic map (NBIT,NBIT_PER_BLOCK)
				port map(A, B, CIN, CO);

end TEST;
