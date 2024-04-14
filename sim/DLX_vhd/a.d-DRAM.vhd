library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;  

-- Data memory for DLX
entity DRAM is
  generic (
    RAM_SIZE : integer := DRAM_SIZE; 
    WORD_SIZE : integer := NumBit 
  );
  port (
    RST  : in  std_logic;  -- Reset input
    ADDR : in  std_logic_vector(WORD_SIZE-1 downto 0);  -- Address input
    DATA_IN :  in std_logic_vector(WORD_SIZE-1 downto 0);  -- Data input for write
    DATA_OUT : out std_logic_vector(WORD_SIZE - 1 downto 0);  -- Data output for read
    SEL: in std_logic_vector(2 downto 0);  -- Selector for different data width reads/writes
    RM: IN std_logic;  -- Read enable
    WM: IN std_logic;  -- Write enable
    EN: IN std_logic;  -- Enable signal
    CLK:in std_logic  -- Clock input
  );
end DRAM;

architecture Behavior of DRAM is
  type memory is array (0 to RAM_SIZE - 1) of std_logic_vector(WORD_SIZE-1 downto 0);  -- Internal memory type
  signal dram_mem : memory;  -- Internal memory instance

begin
  -- Write process (synchronous)
  process(RST,CLK)
  begin
    if(RST = '1') then
      dram_mem <= (others => (others => '0'));  -- Reset the memory to all zeros
    elsif rising_edge(CLK) then
      if(EN='1') then  -- Check if the memory is enabled
        if(WM = '1' ) then  -- Check if write is enabled
          if SEL = "000" then  -- Full word write
            dram_mem(to_integer(unsigned(ADDR))) <= DATA_IN;  -- Write data to the selected address
          elsif SEL = "001" then  -- Write byte of the word
            dram_mem(to_integer(unsigned(ADDR))) <= (WORD_SIZE-1 downto 8 => (DATA_IN(7))) & DATA_IN(7 downto 0);
          elsif SEL = "010" then  -- Write half-word of the word
            dram_mem(to_integer(unsigned(ADDR))) <= (WORD_SIZE-1 downto 16 => (DATA_IN(15))) & DATA_IN(15 downto 0);
          else
            dram_mem(to_integer(unsigned(ADDR))) <= (others=>'0');  -- Write zeros for other cases
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Read process (asynchronous)
  process(EN,RM,ADDR,SEL)
  begin
    if (EN='1') then  -- Check if the memory is enabled
      if (RM= '1') then  -- Check if read is enabled
        if SEL = "000" then  -- Full word read
          DATA_OUT <= dram_mem(to_integer(unsigned(ADDR)));  -- Read data from the selected address
        elsif SEL = "001" then  -- Read byte of the word
          DATA_OUT <= (WORD_SIZE-1 downto 8 => dram_mem(to_integer(unsigned(ADDR)))(7)) & dram_mem(to_integer(unsigned(ADDR)))(7 downto 0);
        elsif SEL = "010" then  -- Read half-word of the word
          DATA_OUT <= (WORD_SIZE-1 downto 16 => dram_mem(to_integer(unsigned(ADDR)))(15)) & dram_mem(to_integer(unsigned(ADDR)))(15 downto 0);
        elsif SEL = "011" then  -- Read byte of the word
          DATA_OUT <= (WORD_SIZE-1 downto 8 => '0') & dram_mem(to_integer(unsigned(ADDR)))(7 downto 0);
        elsif SEL = "100" then  -- Read half-word of the word
          DATA_OUT <= (WORD_SIZE-1 downto 16 => '0') & dram_mem(to_integer(unsigned(ADDR)))(15 downto 0);
        else
          DATA_OUT <= (others=>'0');  -- Put zeros for other cases
        end if;
      end if;
      else
        DATA_OUT <= (others=>'Z');  -- Put in high impedance when unused
    end if;
  end process;

end architecture Behavior;
