-- Testbench for LOGICALS entity

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LOGICALS_tb is
end entity;

architecture tb_arch of LOGICALS_tb is
    -- Constants
    constant NBIT : integer := 32;
    
    -- Signals
    signal A_tb : std_logic_vector(NBIT-1 downto 0);
    signal B_tb : std_logic_vector(NBIT-1 downto 0);
    signal SEL_tb : std_logic_vector(2 downto 0);

    -- LFSR signals
    signal prn, din : std_logic_vector(15 downto 0);
    signal en, reset : std_logic;

    -- Clock signal
    signal clk : std_logic := '1';
    
    -- DUT (Design Under Test) instantiation
    component LOGICALS is
        generic (
            NBIT : integer
        );
        port (
            A : in std_logic_vector(NBIT-1 downto 0);
            B : in std_logic_vector(NBIT-1 downto 0);
            SEL : in std_logic_vector(2 downto 0);
            L : out std_logic_vector(NBIT-1 downto 0)
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
    
    -- Connect DUT ports to signals
    signal L_dut : std_logic_vector(NBIT-1 downto 0);
begin

        -- Initialize signals
	din <= (others => '0');
        en <= '1';
        reset <= '1', '0' after 4 ns;
        A_tb <=  prn(15 downto 8) &prn(7 downto 0) & prn(13 downto 6) & prn (15 downto 14) & prn(5 downto 0);
        B_tb <=  prn(13 downto 6) & prn(15 downto 8) & prn(15 downto 14) & prn (5 downto 0) & prn(7 downto 0);
        -- Apply stimulus

        SEL_tb <= "000", "001" after 4 ns, "010" after 8 ns, "011" after 12 ns, "100" after 16 ns, "101" after 20 ns, "110" after 24 ns;   

clock : process
begin
            wait for 1 ns; -- Clock period
            clk <= not clk;
end process;

    LFSR : LFSR16 port map(clk, reset, '0', en, din, prn, open);

    -- Instantiate the DUT
    dut_inst : LOGICALS
    generic map (
        NBIT => NBIT
    )
    port map (
        A => A_tb,
        B => B_tb,
        SEL => SEL_tb,
        L => L_dut
    );
    
end architecture;