library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.CONSTANTS.ALL;

entity TESTBENCH_COMPARATOR is
end entity;

architecture SIMULATION of TESTBENCH_COMPARATOR is

component COMPARATOR is 
Generic (NBIT: integer:= 16);
Port ( 	A :	In	std_logic_vector(NBIT-1 downto 0);
		B :	In	std_logic_vector(NBIT-1 downto 0);
		DIFF : In std_logic_vector(NBIT-1 downto 0);
        COUT:	In	std_logic; 
       	SEL: in std_logic_vector(3 downto 0); -- MSB = 0 unsigned
        Y:	Out	std_logic_vector(NBIT-1 downto 0));
end component;
constant BIT_TEST :integer := 16;
    signal A, B, DIFF, Y : std_logic_vector(BIT_TEST-1 downto 0);
    signal COUT : std_logic;
    signal SEL : std_logic_vector(3 downto 0);

begin
    -- Instantiate the unit under test (COMPARATOR)
    UUT : COMPARATOR 
        generic map (16)
        port map (A, B, DIFF, COUT, SEL, Y);

    -- Stimulus process
    stimulus_process: process
    begin
        -- SEL = 0000
        A <= "0101010101010101";
        B <= "0011001100110011";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "0000";
        wait for 10 ns;

        -- SEL = 0001
        A <= "1100110011001100";
        B <= "1010101010101010";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "0001";
        wait for 10 ns;

        -- SEL = 0010
        A <= "1010101010101010";
        B <= "1100110011001100";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "0010";
        wait for 10 ns;

        -- SEL = 0011
        A <= "0011001100110011";
        B <= "0101010101010101";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "0011";
        wait for 10 ns;

        -- SEL = 0100
        A <= "0101010101010101";
        B <= "0101010101010101";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "0100";
        wait for 10 ns;

        -- SEL = 0101
        A <= "1100110011001100";
        B <= "1100110011001100";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "0101";
        wait for 10 ns;

        -- SEL = 0110
        A <= "0011001100110011";
        B <= "0011001100110011";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "0110";
        wait for 10 ns;

        -- SEL = 0111
        A <= "1010101010101010";
        B <= "1010101010101010";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "0111";
        wait for 10 ns;

        -- SEL = 1000
        A <= "0101010101010101";
        B <= "0011001100110011";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "1000";
        wait for 10 ns;

        -- SEL = 1001
        A <= "1100110011001100";
        B <= "1010101010101010";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "1001";
        wait for 10 ns;

        -- SEL = 1010
        A <= "1010101010101010";
        B <= "1100110011001100";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "1010";
        wait for 10 ns;

        -- SEL = 1011
        A <= "0011001100110011";
        B <= "0101010101010101";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "1011";
        wait for 10 ns;

        -- SEL = 1100
        A <= "0101010101010101";
        B <= "0101010101010101";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "1100";
        wait for 10 ns;

        -- SEL = 1101
        A <= "1100110011001100";
        B <= "1100110011001100";
        DIFF <= A - B;
        COUT <= '1';
        SEL <= "1101";
        wait for 10 ns;

        -- SEL = 1110
        A <= "0011001100110011";
        B <= "0011001100110011";
        DIFF <= A - B;
        COUT <= '0';
        SEL <= "1110";
        wait for 10 ns;

        -- End simulation
        wait;
    end process stimulus_process;

end architecture SIMULATION;

