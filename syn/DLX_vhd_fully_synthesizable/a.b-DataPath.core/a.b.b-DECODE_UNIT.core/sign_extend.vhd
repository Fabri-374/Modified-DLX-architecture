library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;  

-- Data memory for DLX
entity sign_extend is
  generic (
    NBIT : integer := NumBit;
    IMMEDIATE_LENGTH : integer := IMMEDIATE_LENGTH;
    BRANCHLABEL_LENGTH : integer := BRANCHLABEL_LENGTH
  );
  port (
    DATAIN_16  : in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0); 
    DATAIN_26 : in  std_logic_vector(BRANCHLABEL_LENGTH-1 downto 0);  
    DATAOUT_16U : out std_logic_vector(NBIT-1 downto 0);  
    DATAOUT_16S : out std_logic_vector(NBIT-1 downto 0);  
    DATAOUT_26U : out std_logic_vector(NBIT-1 downto 0);  
    DATAOUT_26S : out std_logic_vector(NBIT-1 downto 0)
  );
end sign_extend;


architecture Behavioral of sign_extend is
  begin
      -- Sign extension for signed numbers
  process (DATAIN_16, DATAIN_26)
  begin
    if DATAIN_16(IMMEDIATE_LENGTH - 1) = '1' then
        -- Negative number, extend with '1's
      DATAOUT_16S(NBIT-1 downto IMMEDIATE_LENGTH) <= (others => '1');
      DATAOUT_16S(IMMEDIATE_LENGTH-1 downto 0) <= DATAIN_16;
    else
        -- Positive number, extend with '0's
      DATAOUT_16S(NBIT-1 downto IMMEDIATE_LENGTH) <= (others => '0');
      DATAOUT_16S(IMMEDIATE_LENGTH-1 downto 0) <= DATAIN_16;
    end if;

    if DATAIN_26(BRANCHLABEL_LENGTH - 1) = '1' then
          -- Negative number, extend with '1's
      DATAOUT_26S(NBIT-1 downto BRANCHLABEL_LENGTH) <= (others => '1');
      DATAOUT_26S(BRANCHLABEL_LENGTH-1 downto 0) <= DATAIN_26;
    else
          -- Positive number, extend with '0's
      DATAOUT_26S(NBIT-1 downto BRANCHLABEL_LENGTH) <= (others => '0');
      DATAOUT_26S(BRANCHLABEL_LENGTH-1 downto 0) <= DATAIN_26;
    end if;
  end process;
    
  -- Sign extension for unsigned numbers
  process (DATAIN_16)
    begin
    -- Always extend with '0's
      DATAOUT_16U(NBIT-1 downto IMMEDIATE_LENGTH) <= (others => '0');
      DATAOUT_16U(IMMEDIATE_LENGTH-1 downto 0) <= DATAIN_16;
      DATAOUT_26U(NBIT-1 downto BRANCHLABEL_LENGTH) <= (others => '0');
      DATAOUT_26U(BRANCHLABEL_LENGTH-1 downto 0) <= DATAIN_26;
  end process;
end architecture Behavioral;