library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;  

entity write_back_unit is
  generic (
    NBIT : integer := NumBit
  );
  port (
    LMD : in std_logic_vector(NBIT-1 downto 0);  -- Input: Next Program Counter
    ALU_DATA : in std_logic_vector(NBIT-1 downto 0);
    SEL : in std_logic;
    DATA_OUT : out std_logic_vector(NBIT-1 downto 0)
  );
end write_back_unit;

architecture structural of write_back_unit is
  -- necessary components instantiation
  component MUX21_GEN is
    Generic (NBIT: integer:= 16);
    Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
             B:	In	std_logic_vector(NBIT-1 downto 0);
             SEL:	In	std_logic;
             Y:	Out	std_logic_vector(NBIT-1 downto 0));
    end component;

-- Declaration of internal signals

begin
  

  MUX_WB: MUX21_GEN generic map(NBIT)
      port map(LMD, ALU_DATA, SEL, DATA_OUT);
  
end structural;