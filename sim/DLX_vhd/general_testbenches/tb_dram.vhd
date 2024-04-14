library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity TB_DRAM is
end TB_DRAM;

architecture Testbench of TB_DRAM is
  -- Constants for simulation
  constant CLOCK_PERIOD: time := 10 ns;
  constant SIMULATION_TIME: time := 380 ns;

  -- Signals for DRAM
  signal RST: std_logic := '1';
  signal ADDR: std_logic_vector(NumBit-1 downto 0) := (others => '0');
  signal DATA_IN: std_logic_vector(NumBit-1 downto 0) := (others => '0');
  signal DATA_OUT: std_logic_vector(NumBit-1 downto 0);
  signal SEL: std_logic_vector(2 downto 0) := "000";
  signal RM: std_logic := '0';
  signal WM: std_logic := '0';
  signal EN: std_logic := '0';
  signal CLK: std_logic := '0';

  -- Instance of DRAM
  component DRAM
    generic (
      RAM_SIZE : integer := DRAM_SIZE;
      WORD_SIZE : integer := NumBit
    );
    port (
      RST  : in  std_logic;
      ADDR : in  std_logic_vector(WORD_SIZE-1 downto 0);
      DATA_IN :  in std_logic_vector(WORD_SIZE-1 downto 0);
      DATA_OUT : out std_logic_vector(WORD_SIZE - 1 downto 0);
      SEL: in std_logic_vector(2 downto 0);
      RM: IN std_logic;
      WM: IN std_logic;
      EN: IN std_logic;
      CLK:in std_logic
    );
  end component;

begin
  -- Instantiate DRAM
  DRAM_inst: DRAM
    generic map (
      RAM_SIZE => DRAM_SIZE,
      WORD_SIZE => NumBit
    )
    port map (
      RST => RST,
      ADDR => ADDR,
      DATA_IN => DATA_IN,
      DATA_OUT => DATA_OUT,
      SEL => SEL,
      RM => RM,
      WM => WM,
      EN => EN,
      CLK => CLK
    );

  -- Clock generation process
  process
  begin
    CLK <= '0';
    wait for CLOCK_PERIOD / 2;
    CLK <= '1';
    wait for CLOCK_PERIOD / 2;
  end process;

  -- Stimulus process
  process
  begin
    -- Reset initialization
    RST <= '1';
    wait for CLOCK_PERIOD;

    -- Release reset and start enabling the memory
    RST <= '0';
    EN <= '1';
    wait for CLOCK_PERIOD;

    -- Perform write operations
    ADDR <= "00000000000000000000000010000000";  -- Set address for write
    DATA_IN <= "11111111000000001111111100000000";  -- Set data for write
    WM <= '1';  -- Enable write
    wait for CLOCK_PERIOD;
    WM <= '0';  -- Disable write
    wait for CLOCK_PERIOD;

    -- Perform read operations
    ADDR <= "00000000000000000000000000000000";  -- Set address for read
    SEL <= "000";  -- Set selector for full word read
    RM <= '1';  -- Enable read
    wait for CLOCK_PERIOD;
    RM <= '0';  -- Disable read
    wait for CLOCK_PERIOD;

    -- Perform read and write test cases for all SEL combinations
    for i in 0 to 7 loop
      
      -- Perform write test cases for all SEL combinations
      ADDR <= std_logic_vector(unsigned(ADDR) + "01");
      DATA_IN <= std_logic_vector(to_unsigned(i * 85, NumBit));
      WM <= '1';  -- Enable write
      wait for CLOCK_PERIOD;
      WM <= '0';  -- Disable write
      wait for CLOCK_PERIOD;

      SEL <= std_logic_vector(to_unsigned(i, 3));
      RM <= '1';  -- Enable read
      wait for CLOCK_PERIOD;
      RM <= '0';  -- Disable read
      wait for CLOCK_PERIOD;
    end loop;

    -- End simulation
    wait for SIMULATION_TIME;
    wait;
  end process;

end Testbench;