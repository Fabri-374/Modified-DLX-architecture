library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RCA_GEN is 
	generic (
		NBIT: integer := 16
	);
	port (
		A:   in std_logic_vector(NBIT-1 downto 0);
		B:   in std_logic_vector(NBIT-1 downto 0);
		Ci:  in std_logic;
		S:   out std_logic_vector(NBIT-1 downto 0);
		Co:  out std_logic
	);
end RCA_GEN; 

architecture STRUCTURAL of RCA_GEN is

	signal STMP : std_logic_vector(NBIT-1 downto 0);
	signal CTMP : std_logic_vector(NBIT downto 0);

	component FA
		port (
			A:   in std_logic;
			B:   in std_logic;
			Ci:  in std_logic;
			S:   out std_logic;
			Co:  out std_logic
		);
	end component;

begin

	CTMP(0) <= Ci;
	S <= STMP;
	Co <= CTMP(NBIT);

	-- Ripple Carry Adder (RCA) logic implementation
	ADDERS: for I in 1 to NBIT generate
		FAI : FA
			port map (
				A => A(I-1),
				B => B(I-1),
				Ci => CTMP(I-1),
				S => STMP(I-1),
				Co => CTMP(I)
			);
	end generate;

end STRUCTURAL;

configuration CFG_RCA_STRUCTURAL of RCA_GEN is
	for STRUCTURAL 
		for ADDERS
			for all : FA
				use configuration WORK.CFG_FA_BEHAVIORAL;
			end for;
		end for;
	end for;
end CFG_RCA_STRUCTURAL;

