-- Testbench for ALU entity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end entity;

architecture tb_arch of ALU_tb is
    -- Constants
    constant NBIT : integer := 32;
    constant NBIT_PER_BLOCK : integer := 4;
    
    -- Signals
    signal A_tb : std_logic_vector(NBIT-1 downto 0);
    signal B_tb : std_logic_vector(NBIT-1 downto 0);
    signal MODE_tb : std_logic_vector(4 downto 0);
    signal S_tb : std_logic_vector(NBIT-1 downto 0);

    -- Clock signal
    signal clk : std_logic := '1';

    -- LFSR signals
    signal prn, din : std_logic_vector(15 downto 0);
    signal en, reset : std_logic;
    
    -- DUT (Design Under Test) instantiation
    component ALU is
        generic (
            NBIT : integer := 32;
            NBIT_PER_BLOCK : integer := 4
        );
        port (
            A : in std_logic_vector(NBIT-1 downto 0);
            B : in std_logic_vector(NBIT-1 downto 0);
            MODE: in std_logic_vector(4 downto 0);
            S : out std_logic_vector(NBIT-1 downto 0)
        );
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

begin

    A_tb <=  prn(15 downto 8) &prn(7 downto 0) & prn(13 downto 6) & prn (15 downto 14) & prn(5 downto 0);
    B_tb <=  prn(13 downto 6) & prn(15 downto 8) & prn(15 downto 14) & prn (5 downto 0) & prn(7 downto 0);

-- Stimulus process
process
begin
    -- Initialize signals
    en <= '1';
    din <= (others => '0');
    reset <= '1';
    MODE_tb <= "00000";
    -- Apply stimulus
    wait for 4 ns; -- Initial delay
    reset <= '0';
    MODE_tb <= "00000"; -- 0
                wait for 4 ns;
                    MODE_tb <= "00001"; -- add
                wait for 4 ns;
                    MODE_tb <= "00011"; -- and
                wait for 4 ns;
                    MODE_tb <= "01010"; -- or
                wait for 4 ns;
                    MODE_tb <= "01100"; -- sge
                wait for 4 ns;
                    MODE_tb <= "10000"; -- sle
                wait for 4 ns;
                    MODE_tb <= "10010"; -- sll
                wait for 4 ns;
                    MODE_tb <= "10101"; -- sne
                wait for 4 ns;
                    MODE_tb <= "10111"; -- srl
                wait for 4 ns;
                    MODE_tb <= "11000"; -- sub
                wait for 4 ns;
                    MODE_tb <= "11010"; -- xor
                wait for 4 ns;
                    MODE_tb <= "00000"; -- Default case
                wait for 4 ns;
		-- test of added instructions --
                    MODE_tb <= "01011"; -- seq
                wait for 4 ns;
                    MODE_tb <= "01110"; -- sgt
                wait for 4 ns;
                    MODE_tb <= "10011"; -- slt
                wait;
end process;

clock_gen : process
begin
        wait for 1 ns; -- Clock period
        clk <= not clk;
end process;

LFSR : LFSR16 port map(clk, reset, '0', en, din, prn, open);

    -- Instantiate the DUT
    dut_inst : ALU
    generic map (
        NBIT => NBIT,
        NBIT_PER_BLOCK => NBIT_PER_BLOCK
    )
    port map (
        A => A_tb,
        B => B_tb,
        MODE => MODE_tb,
        S => S_tb
    );
    
end architecture;