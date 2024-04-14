library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.constants.all;

entity FETCH_UNIT is
  generic (
    I_SIZE : integer := 32
  );
  port (
    DOUT : in std_logic_vector(I_SIZE - 1 downto 0);
    PC : in std_logic_vector(I_SIZE - 1 downto 0);
    EN_PC : in std_logic;
    EN_F : in std_logic;
    SEL_BRANCH : in std_logic;
    CLK : in std_logic;
    RES : in std_logic;
    ADDR : out std_logic_vector(I_SIZE - 1 downto 0);
    NPC : out std_logic_vector(I_SIZE - 1 downto 0);
    IR : out std_logic_vector(I_SIZE - 1 downto 0)
  );
end FETCH_UNIT;

architecture STRUCTURAL of FETCH_UNIT is

  component RCA_GEN is 
    generic (NBIT: integer := 16);
    Port (
      A: in std_logic_vector(NBIT-1 downto 0);
      B: in std_logic_vector(NBIT-1 downto 0);
      Ci: in std_logic;
      S: out std_logic_vector(NBIT-1 downto 0);
      Co: out std_logic);
  end component; 

  component FD_GEN is
    Generic (NBIT: integer := 16);
    Port (D: in std_logic_vector(NBIT-1 downto 0);
          CK: in std_logic;
          EN: in std_logic;
          RESET: in std_logic;
          Q: out std_logic_vector(NBIT-1 downto 0));
  end component;

  component MUX21_GEN is
  Generic (NBIT: integer:= 16);
  Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
          B:	In	std_logic_vector(NBIT-1 downto 0);
          SEL:	In	std_logic;
          Y:	Out	std_logic_vector(NBIT-1 downto 0));
  end component;

  signal s_out, pc_out, next_pc: std_logic_vector(NBIT-1 downto 0);
  signal cout: std_logic;

begin

  -- Instantiate the NEXT_PC mux 
  NEXT_PC_MUX: MUX21_GEN
    generic map(NBIT)
    port map (
      A => PC, -- PC for branch or jump
      B => s_out, -- NPC -> PC + 4
      SEL => SEL_BRANCH,
      Y => next_pc
    );

  -- Instantiate FD_GEN for the PC register
  PC_REG : FD_GEN
    generic map(NBIT)
    port map (
      D => next_pc,
      CK => CLK,
      EN => EN_PC,
      RESET => RES,
      Q => pc_out
    );

  -- Instantiate RCA_GEN for generating PC + 4
  ADDER: RCA_GEN
    generic map(NBIT)
    port map (
      A => pc_out,
      B => x"00000004",
      Ci => '0',
      S => s_out,
      Co => cout
    );

  -- Instantiate FD_GEN for the IR register
  IR_REG : FD_GEN
    generic map(NBIT)
    port map (
      D => DOUT,
      CK => CLK,
      EN => EN_F,
      RESET => RES,
      Q => IR
    );

  -- Instantiate FD_GEN for the NPC register
  NPC_REG : FD_GEN
    generic map(NBIT)
    port map (
      D => s_out,
      CK => CLK,
      EN => EN_F,
      RESET => RES,
      Q => NPC
    );

  -- Connect ADDR to PC_OUT
  ADDR <= pc_out;

end STRUCTURAL;

