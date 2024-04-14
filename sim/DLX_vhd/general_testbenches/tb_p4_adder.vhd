library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture TEST of TB_P4_ADDER is
	
	-- P4 component declaration
	component P4_ADDER is
		generic (
			NBIT :		integer := 32;
			NBIT_PER_BLOCK : integer := 4);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :		out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic);
	end component;
	
	component LFSR16 is 
 	port( 
    		CLK : in std_logic; 
   	 	RESET : in std_logic; 
    		LD : in std_logic; 
   		EN : in std_logic; 
    		DIN : in std_logic_vector (0 to 15); 
    		PRN : out std_logic_vector (0 to 15); 
   	 	ZERO_D : out std_logic);
	end component;

	constant NBIT : integer := 32;
	constant NBIT_PER_BLOCK : integer := 4;
	
	signal A, B, S, A_LFSR, B_LFSR, S_LFSR: std_logic_vector(NBIT-1 downto 0);
	signal Cin, Cout,Cout_LFSR : std_logic;

	constant Period: time := 5 ns; -- Clock period (1 GHz)
	signal CLK : std_logic := '0';
  	signal RESET,LD,EN,ZERO_D : std_logic;
  	signal DIN, PRN : std_logic_vector(15 downto 0);

	
begin	

	-- Create the permanent Clock and the Reset pulse
  	CLK <= not(CLK) after Period/2;
  	RESET <= '1', '0' after Period;
	-- Open file, make a load, and wait for a timeout in case of design error.
  	STIMULUS1: process
  	begin
    		DIN <= "0000000000000001";
	    	EN <='1';
    		LD <='1';
 	   	wait for 2 * PERIOD;
	    	LD <='0';
    		wait for (65600 * PERIOD);
  	end process STIMULUS1;


	-- we tested some critical cases, the same as the previous testbenches --
	A <= "00011111000111110001111100011111", x"FFFFFFFF" after 10 ns, x"F10E8247" after 20 ns, x"FFFFFFFF" after 30 ns, x"00000000" after 40 ns, x"FFFFFFFF" after 50 ns; --A_LFSR AFTER 60 NS;
	B <= "11111000111110001111100011111000", x"00000001" after 10 ns, x"FFF26342" after 20 ns, x"00010000" after 30 ns, x"00000000" after 40 ns;
	Cin <= '0',  '1' after 50 ns;
	
	-- signals for random cases --
	A_LFSR <= PRN & PRN;
	B_LFSR <= PRN(2 DOWNTO 0) & PRN(15 DOWNTO 3) & PRN(7 DOWNTO 0) & PRN(15 DOWNTO 8);

	-- Instanciate the Unit Under Test (UUT)
  	UUT: LFSR16 port map (CLK=>CLK, RESET=>RESET, LD=>LD, EN=>EN, 
                        	DIN=>DIN, PRN=>PRN, ZERO_D=>ZERO_D);

	P4: P4_ADDER generic map (NBIT, NBIT_PER_BLOCK)
			port map (A, B, Cin, S, Cout);

	P4_1: P4_ADDER generic map (NBIT, NBIT_PER_BLOCK)
			port map (A_LFSR, B_LFSR, Cin, S_LFSR, Cout_LFSR);
	
end TEST;

