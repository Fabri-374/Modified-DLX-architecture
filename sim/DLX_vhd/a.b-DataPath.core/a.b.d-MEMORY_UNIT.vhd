library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;  
use WORK.functions.all;

entity memory_unit is
  generic (
    NBIT : integer := NumBit
  );
  port (
    PC_PLUS_4 : in std_logic_vector(NBIT-1 downto 0);  
    EN_LMD : in std_logic;  
    CLK : in std_logic;      -- Input: Clock
    RES : in std_logic;      -- Input: Reset Signal
    RD : in std_logic_vector(4 downto 0); -- Input: register destination propagation
    DRAM_DATA : in std_logic_vector(NBIT-1 downto 0);
    ALU_DATA : in std_logic_vector(NBIT-1 downto 0);
    RD_OUT : out std_logic_vector(4 downto 0);
    LMD : out std_logic_vector(NBIT-1 downto 0);  -- Output: Execution Unit Output
    PC_PLUS_4_OUT : out std_logic_vector(NBIT-1 downto 0); 
    ALU_DATA_OUT : out std_logic_vector(NBIT-1 downto 0)
  );
end memory_unit;

architecture structural of memory_unit is
    -- necessary components instantiation
    component FD_GEN is
        Generic (NBIT: integer:= 16);
            Port (	D:	In	std_logic_vector(NBIT-1 downto 0);
                CK:	In	std_logic;
                EN : in std_logic;
                RESET:	In	std_logic;
                Q:	Out	std_logic_vector(NBIT-1 downto 0));
    end component;

  -- Declaration of internal signals

begin
    

    ALU_OUT_REG: FD_GEN generic map(NBIT)
        port map(ALU_DATA, CLK, EN_LMD, RES, ALU_DATA_OUT);
    
    LMD_REG: FD_GEN generic map(NBIT)
        port map(DRAM_DATA, CLK, EN_LMD, RES, LMD);

    PC_REG: FD_GEN generic map(NBIT)
        port map(PC_PLUS_4, CLK, EN_LMD, RES, PC_PLUS_4_OUT);

    RD_REG: FD_GEN generic map(5)
        port map(RD, CLK, EN_LMD, RES, RD_OUT);


end structural;