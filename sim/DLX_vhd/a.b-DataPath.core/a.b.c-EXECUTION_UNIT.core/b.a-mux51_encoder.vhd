library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MUX51 is
  generic (NBIT: integer := 32);
  Port (A: in std_logic_vector(NBIT-1 downto 0);
        A_2: in std_logic_vector(NBIT-1 downto 0);
        ZEROS: in std_logic_vector(NBIT-1 downto 0);
        SEL : in std_logic_vector(2 downto 0);
        Y: out std_logic_vector(NBIT -1 downto 0)
  );
end MUX51;

architecture STRUCTURAL of MUX51 is

  component MUX21_GEN
    Generic (NBIT: integer := 16);
    Port (A: in std_logic_vector(NBIT-1 downto 0);
          B: in std_logic_vector(NBIT-1 downto 0);
          SEL: in std_logic;
          Y: out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  signal outmux_1, outmux_2, outmux_3, outmux_4: std_logic_vector(NBIT-1 downto 0);
  signal selmux12, selmux4, selmux5: std_logic;
  signal not_zeros, not_a_2, not_a: std_logic_vector(NBIT-1 downto 0);

begin

  -- negate signals to implement the negative values of A and 2A --
  not_zeros <= not ZEROS;
  not_a <= not A;
  not_a_2 <= not A_2;

  -- implementation of selectors for the tree mux structure --
  selmux12 <= SEL(1) xor SEL(0);
  selmux4 <= (SEL(2) xor SEL(1)) or (SEL(2) xor SEL(0));
  selmux5 <= SEL(2) and SEL(1) and SEL(0);

  -- tree structure mux implementation --
  MUX1: mux21_gen
    generic map (NBIT)
    port map (
      A => A,
      B => A_2,
      SEL => selmux12,
      Y => outmux_1
    );

  MUX2: mux21_gen
    generic map (NBIT)
    port map (
      A => NOT_A,
      B => NOT_A_2,
      SEL => selmux12,
      Y => outmux_2
    );

  MUX3: mux21_gen
    generic map (NBIT)
    port map (
      A => outmux_2,
      B => outmux_1,
      SEL => SEL(2),
      Y => outmux_3
    );

  MUX4: mux21_gen
    generic map (NBIT)
    port map (
      A => outmux_3,
      B => ZEROS,
      SEL => selmux4,
      Y => outmux_4
    );

  MUX5: mux21_gen
    generic map (NBIT)
    port map (
      A => not_zeros,
      B => outmux_4,
      SEL => selmux5,
      Y => Y
    );

--we used MUX5 in order to have the possibility to use the sel2 as Cin for the RCA to implement with t
--he same Adder the sum or the subtraction.

end STRUCTURAL;
