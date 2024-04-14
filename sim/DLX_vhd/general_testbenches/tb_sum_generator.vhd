library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TBSUM_GENERATOR is 
end TBSUM_GENERATOR; 

architecture TEST of TBSUM_GENERATOR is


	component SUM_GENERATOR is
		generic (
			NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
		port (
			A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
			S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
	end component;

-- We use 8 carry select blocks each one with 4 bit RCA --
signal A, B, S : std_logic_vector(31 downto 0); 
signal C : std_logic_vector(7 downto 0);

begin

	-- we tested some critical cases with their real carries --

	C <= "00000000", 			"10101010" after 10 ns, 			"11111110" after 20 ns,  x"E0" after 30 ns,					x"00" after 50 ns;					
	A <= "00010001000100010001000100010001", "00011111000111110001111100011111" after 10 ns, x"FFFFFFFF" after 20 ns, x"FFFFFFFF" after 30 ns, x"F10E8247" after 40 ns, x"00000000" after 50 ns, x"FFFFFFFF" after 60 ns;
	B <= "00010001000100010001000100010001", "00011111000111110001111100011111" after 10 ns, x"00000001" after 20 ns, x"00010000" after 30 ns, x"FFF26342" after 40 ns, x"00000000" after 50 ns;

	
	Test_sum: SUM_GENERATOR generic map (4, 8)
				port map(A, B, C, S);

end TEST;

configuration SUM_GENERATORTEST of TBSUM_GENERATOR is
  for TEST
    for all: SUM_GENERATOR
      use configuration WORK.CFG_SUM_GENERATOR_STRUCTURAL;
    end for;
  end for;
end SUM_GENERATORTEST;
