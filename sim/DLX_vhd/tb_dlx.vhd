library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.myTypes.all;

-- Testbench for DLX entity
entity DLX_tb is
end entity;

architecture tb_arch of DLX_tb is

	component DLX is
  generic (NBIT : integer := NumBit;
	   NBIT_PER_BLOCK : integer := NBIT_PER_BLOCK
  );
  port (
    CLK : in std_logic;
    RES : in std_logic
    );
  end component;

  signal clk : std_logic := '0';
  signal reset: std_logic := '1';

begin

-- Stimulus process
  stim : process
  begin
      wait until clk'event and clk='1'; -- Initial delay
      reset <= '0';

  end process;

  clock_gen : process
  begin
          wait for 1 ns; -- Clock period
          clk <= not clk;
  end process;

  test: DLX port map(clk, reset);
    
end architecture tb_arch;
