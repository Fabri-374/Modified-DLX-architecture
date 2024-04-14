library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity MUX41_GEN is
  Generic (NBIT: integer := NumBit);
  Port (A: in std_logic_vector(NBIT-1 downto 0);
        B: in std_logic_vector(NBIT-1 downto 0);
        C: in std_logic_vector(NBIT-1 downto 0);
        D: in std_logic_vector(NBIT-1 downto 0);
        Sel: in std_logic_vector(1 downto 0);
        Y: out std_logic_vector(NBIT-1 downto 0)
  );
end MUX41_GEN;

architecture STRUCTURAL of MUX41_GEN is

  signal out_mux1, out_mux2: std_logic_vector(NBIT-1 downto 0);

  component MUX21_GEN
    Generic (NBIT: integer := 16);
    Port (A: in std_logic_vector(NBIT-1 downto 0);
          B: in std_logic_vector(NBIT-1 downto 0);
          SEL: in std_logic;
          Y: out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

begin

  -- Instantiate MUX21_GEN for the first mux
  MUX1: MUX21_GEN
    Generic map (NBIT)
    Port map (
      A => B,
      B => A,
      SEL => Sel(0),
      Y => out_mux1
    );

  -- Instantiate MUX21_GEN for the second mux
  MUX2: MUX21_GEN
    Generic map (NBIT)
    Port map (
      A => D,
      B => C,
      SEL => Sel(0),
      Y => out_mux2
    );

  -- Instantiate MUX21_GEN for the final mux
  MUX3: MUX21_GEN
    Generic map (NBIT)
    Port map (
      A => out_mux2,
      B => out_mux1,
      SEL => Sel(1),
      Y => Y
    );

end STRUCTURAL;

