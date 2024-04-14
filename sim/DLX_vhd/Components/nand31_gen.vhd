-- 3-to-1 NAND gate with parametric inputs and output
-- Behavioral implementation

library ieee;
use ieee.std_logic_1164.all;

entity NAND31_GEN is
  generic (
    NBIT : integer := 32);
  port (
    A    : in  std_logic_vector(NBIT-1 downto 0);
    B    : in  std_logic_vector(NBIT-1 downto 0);
    C    : in  std_logic_vector(NBIT-1 downto 0);
    Y    : out std_logic_vector(NBIT-1 downto 0));
end NAND31_GEN;

architecture behavioral of NAND31_GEN is
begin

    Y <= not (A and B and C); -- Output is the logical NAND of inputs A, B, and C

end architecture behavioral;