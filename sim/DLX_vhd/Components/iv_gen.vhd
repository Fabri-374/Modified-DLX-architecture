-- Parametric inverter component -- 

library ieee;
use ieee.std_logic_1164.all;

entity IV_GEN is
  generic (
    NBIT : integer := 32);
  port (
    A    : in  std_logic_vector(NBIT-1 downto 0);
    Y    : out std_logic_vector(NBIT-1 downto 0));
end IV_GEN;

architecture behavioral of IV_GEN is
begin

  Y <= not A; -- Output is the logical inverse of input A

end architecture behavioral;