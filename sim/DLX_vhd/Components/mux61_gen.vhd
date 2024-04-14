-- general 6-1 mux with parametric inputs and output -- 
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MUX61_GEN is
  Generic (NBIT: integer := 16);
  Port (A: in std_logic_vector(NBIT-1 downto 0);
        B: in std_logic_vector(NBIT-1 downto 0);
        C: in std_logic_vector(NBIT-1 downto 0);
        D: in std_logic_vector(NBIT-1 downto 0);
        E: in std_logic_vector(NBIT-1 downto 0);
        F: in std_logic_vector(NBIT-1 downto 0);
        SEL: in std_logic_vector(2 downto 0);
        Y: out std_logic_vector(NBIT-1 downto 0)
  );
end entity;

architecture structural of MUX61_GEN is

  component MUX21_GEN
    Generic (NBIT: integer := 16);
    Port (A: in std_logic_vector(NBIT-1 downto 0);
          B: in std_logic_vector(NBIT-1 downto 0);
          SEL: in std_logic;
          Y: out std_logic_vector(NBIT-1 downto 0)
    );
  end component MUX21_GEN;

  signal out_mux1, out_mux2, out_mux3, out_mux4 : std_logic_vector(NBIT-1 downto 0);

begin

  -- the mux provides at the output a different input based on the combination of SEL signal bits:
  -- SEL = "000" -> A
  -- SEL = "001" -> B
  -- SEL = "010" -> C
  -- SEL = "011" -> D
  -- SEL = "100" -> E
  -- SEL = "101" -> F --

  -- MUX1: Selects between B and A based on SEL(0) --
  MUX1: MUX21_GEN
    generic map (NBIT)
    port map (
      A => B,
      B => A,
      SEL => SEL(0),
      Y => out_mux1
    );

  -- MUX2: Selects between D and C based on SEL(0) --
  MUX2: MUX21_GEN
    generic map (NBIT)
    port map (
      A => D,
      B => C,
      SEL => SEL(0),
      Y => out_mux2
    );

  -- MUX3: Selects between F and E based on SEL(0) --
  MUX3: MUX21_GEN
    generic map (NBIT)
    port map (
      A => F,
      B => E,
      SEL => SEL(0),
      Y => out_mux3
    );

  -- MUX4: Selects between the output of MUX2 and MUX1 based on SEL(1) --
  MUX4: MUX21_GEN
    generic map (NBIT)
    port map (
      A => out_mux2,
      B => out_mux1,
      SEL => SEL(1),
      Y => out_mux4
    );

  -- MUX5: Selects between the output of MUX3 and the output of MUX4 based on SEL(2) --
  MUX5: MUX21_GEN
    generic map (NBIT)
    port map (
      A => out_mux3,
      B => out_mux4,
      SEL => SEL(2),
      Y => Y
    );

end architecture structural;

