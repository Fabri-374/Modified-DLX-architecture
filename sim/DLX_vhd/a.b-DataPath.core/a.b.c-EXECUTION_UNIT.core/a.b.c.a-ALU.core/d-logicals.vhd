-- implementation of the T2 logic unit based on the nand tree where the combination --
-- of the SEL signal bits provides at the output different logic bitwise operation -- 

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LOGICALS is 
    generic(NBIT: integer);
	port(	
    A: in std_logic_vector(NBIT-1 downto 0);
		B: in std_logic_vector(NBIT-1 downto 0);
    SEL: in std_logic_vector(2 downto 0);
		L: out std_logic_vector(NBIT-1 downto 0));
end entity;

architecture structural of LOGICALS is

-- the necessary components in this architecture are the 3-to-1 nands, the output 4-to-1 nand and the inverter --

component IV_GEN is
    generic (
        NBIT : integer := 32);
    port (
        A    : in  std_logic_vector(NBIT-1 downto 0);
        Y    : out std_logic_vector(NBIT-1 downto 0));
    end component;

component NAND31_GEN is
    generic (
        NBIT : integer := 32);
    port (
        A    : in  std_logic_vector(NBIT-1 downto 0);
        B    : in  std_logic_vector(NBIT-1 downto 0);
        C    : in  std_logic_vector(NBIT-1 downto 0);
        Y    : out std_logic_vector(NBIT-1 downto 0));
end component;

component NAND41_GEN is
    generic (
      NBIT : integer := 32);
    port (
      A    : in  std_logic_vector(NBIT-1 downto 0);
      B    : in  std_logic_vector(NBIT-1 downto 0);
      C    : in  std_logic_vector(NBIT-1 downto 0);
      D    : in  std_logic_vector(NBIT-1 downto 0);
      Y    : out std_logic_vector(NBIT-1 downto 0));
  end component;

    signal out_nand1, out_nand2, out_nand3, out_nand4 : std_logic_vector(NBIT-1 downto 0); -- signals to create the nand-tree -- 
    signal not_a, not_b : std_logic_vector(NBIT-1 downto 0); -- negated signals obtained with the inverter -- 
    signal s0, s1, s2 : std_logic_vector(NBIT-1 downto 0); -- extended SEL(i) to perform bitwise operations -- 

begin

  -- to use parametric and more generic bitwise nand, we decided to extend the value of the three control signals --  

  s0 <= (others => SEL(0));
  s1 <= (others => SEL(1));
  s2 <= (others => SEL(2));

  -- nand-tree implementation with the following logical output depending on SEL input signal:
  -- SEL = "100" -> AND
  -- SEL = "011" -> NAND
  -- SEL = "110" -> OR
  -- SEL = "001" -> NOR
  -- SEL = "010" -> XOR
  -- SEL = "101" -> XNOR

  -- Instantiate the inverters to generate NOT A and NOT B
  NEG_A : IV_GEN generic map(NBIT)
    port map (
      A => A,
      Y => not_a
    );
  NEG_B : IV_GEN generic map(NBIT)
    port map (
      A => B,
      Y => not_b
    );

  -- Instantiate NAND31_GEN for NAND1
  NAND1 : NAND31_GEN generic map(NBIT)
    port map (
      A => not_a,
      B => not_b,
      C => s0,
      Y => out_nand1
    );

  -- Instantiate NAND31_GEN for NAND2
  NAND2 : NAND31_GEN generic map(NBIT)
    port map (
      A => not_a,
      B => B,
      C => s1,
      Y => out_nand2
    );

  -- Instantiate NAND31_GEN for NAND3
  NAND3 : NAND31_GEN generic map(NBIT)
    port map (
      A => A,
      B => not_b,
      C => s1,
      Y => out_nand3
    );

  -- Instantiate NAND31_GEN for NAND4
  NAND4 : NAND31_GEN generic map(NBIT)
    port map (
      A => A,
      B => B,
      C => s2,
      Y => out_nand4
    );

  -- Instantiate NAND41_GEN for final output
  NAND5 : NAND41_GEN generic map(NBIT)
    port map (
      A => out_nand1,
      B => out_nand2,
      C => out_nand3,
      D => out_nand4,
      Y => L
    );

end structural;
