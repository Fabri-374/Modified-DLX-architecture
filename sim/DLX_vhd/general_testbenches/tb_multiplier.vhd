library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use WORK.constants.all;

entity MULTIPLIER_tb is
end MULTIPLIER_tb;


architecture TEST of MULTIPLIER_tb is


  constant numBit : integer := 8;  --:=16    

  --  input	 
  signal A_mp_i : std_logic_vector(numBit -1 downto 0) := (others => '0');
  signal B_mp_i : std_logic_vector(numBit -1 downto 0) := (others => '0');

  -- output
  signal Y_mp_i : std_logic_vector(numBit*2-1 downto 0);


component BOOTHMUL is
	generic (NBIT: 		integer := 32);
	Port (	A:	In	std_logic_vector(NBIT -1 downto 0);
		B:	In	std_logic_vector(NBIT -1 downto 0);
		P:	Out	std_logic_vector(NBIT*2 -1 downto 0));
end component; 


begin

TESTMUL : BOOTHMUL generic map(NumBit)
		port map(A_mp_i, B_mp_i, Y_mp_i);


-- PROCESS FOR TESTING TEST - COMPLETE CYCLE ---------
  test: process
  begin

    -- cycle for operand A
    NumROW : for i in 0 to 2**(NumBit)-1 loop 
        -- cycle for operand B
    	NumCOL : for i in 0 to 2**(NumBit)-1 loop
	    wait for 0.1 ns;
	    B_mp_i <= B_mp_i + '1';
	end loop NumCOL ;
	A_mp_i <= A_mp_i + '1'; 
    end loop NumROW ;

    wait;          
  end process test;


end TEST;
