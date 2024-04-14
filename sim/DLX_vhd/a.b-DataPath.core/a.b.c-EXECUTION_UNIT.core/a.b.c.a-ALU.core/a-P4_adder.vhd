library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity P4_ADDER is
  generic (
    NBIT : integer := 32;
    NBIT_PER_BLOCK : integer := 4
  );
  port (
    A : in std_logic_vector(NBIT-1 downto 0);
    B : in std_logic_vector(NBIT-1 downto 0);
    Cin : in std_logic;
    S : out std_logic_vector(NBIT-1 downto 0);
    Cout : out std_logic
  );
end entity;

architecture STRUCTURAL of P4_ADDER is

  -- components declaration --

  component SUM_GENERATOR
    generic (
      NBIT_PER_BLOCK: integer := 4;
      NBLOCKS : integer := 8
    );
    port (
      A : in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0);
      B : in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0);
      Ci : in std_logic_vector(NBLOCKS -1 downto 0);
      S : out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0)
    );
  end component;

  component CARRY_GENERATOR
    generic (
      NBIT : integer := 32;
      NBIT_PER_BLOCK: integer := 4
    );
    port (
      A : in std_logic_vector(NBIT-1 downto 0);
      B : in std_logic_vector(NBIT-1 downto 0);
      Cin : in std_logic;
      Co : out std_logic_vector((NBIT/NBIT_PER_BLOCK-1) downto 0)
    );
  end component;

  -- signals declaration --
  signal C_carry_gen : std_logic_vector(NBIT/NBIT_PER_BLOCK-1 downto 0);
  signal Cin_tmp: std_logic_vector(NBIT/NBIT_PER_BLOCK -1 downto 0);

begin
  -- Carry generation logic
  Cin_tmp <= C_carry_gen(NBIT/NBIT_PER_BLOCK-2 downto 0) & Cin;
  Cout <= C_carry_gen(NBIT/NBIT_PER_BLOCK-1);

  -- Instantiate CARRY_GENERATOR
  CARRY_GEN : CARRY_GENERATOR
    generic map (NBIT, NBIT_PER_BLOCK)
    port map (
      A => A,
      B => B,
      Cin => Cin,
      Co => C_carry_gen
    );

  -- Instantiate SUM_GENERATOR
  SUM_GEN : SUM_GENERATOR
    generic map (NBIT_PER_BLOCK, NBIT/NBIT_PER_BLOCK)
    port map (
      A => A,
      B => B,
      Ci => Cin_tmp,
      S => S
    );

end architecture;

