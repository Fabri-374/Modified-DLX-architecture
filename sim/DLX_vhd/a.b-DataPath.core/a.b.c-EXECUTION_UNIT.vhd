library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;
use WORK.functions.all;

entity Execution_unit is
  generic (
    NBIT : integer := NumBit;
    NBIT_PER_BLOCK: integer := NBIT_PER_BLOCK
  );
  port (
    NPC : in std_logic_vector(NBIT-1 downto 0);
    A : in std_logic_vector(NBIT-1 downto 0);
    B : in std_logic_vector(NBIT-1 downto 0);
    IMM : in std_logic_vector(NBIT-1 downto 0);
    SEL_A : in std_logic;
    SEL_B : in std_logic;
    SEL_EXE_TYPE : in std_logic;
    ALU_MODE : in std_logic_vector(5 downto 0);
    EN_ALU : in std_logic;
    CLK : in std_logic;
    RES : in std_logic;
    RD : in std_logic_vector(4 downto 0);
    SEL_MUX_JUMP : in std_logic;
    SEL_LHI : in std_logic;  
    SEL_FW_A : in std_logic_vector(1 downto 0);  
    SEL_FW_B : in std_logic_vector(1 downto 0);
    MEM_DATA : in std_logic_vector(NBIT-1 downto 0);
    ADDR_DRAM : out std_logic_vector(NBIT-1 downto 0);
    RD_OUT : out std_logic_vector(4 downto 0);
    EXE_OUT : out std_logic_vector(NBIT-1 downto 0);
    PC_PLUS_4 : out std_logic_vector(NBIT-1 downto 0);
    PC_OUT : out std_logic_vector(NBIT-1 downto 0)
  );
end Execution_unit;

architecture structural of Execution_unit is
  component BOOTHMUL is
    generic (NBIT: integer := 32);
    Port (
      A:    in  std_logic_vector(NBIT -1 downto 0);
      B:    in  std_logic_vector(NBIT -1 downto 0);
      P:    out std_logic_vector(NBIT*2 -1 downto 0)
    );
  end component;

  component ALU is
    generic (
      NBIT :        integer := 32;
      NBIT_PER_BLOCK : integer := 4
    );
    port (
      A :    in  std_logic_vector(NBIT-1 downto 0);
      B :    in  std_logic_vector(NBIT-1 downto 0);
      SEL_LHI : in std_logic;
      MODE:   in std_logic_vector(5 downto 0);
      S :    out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  component MUX21_GEN is
    Generic (NBIT: integer:= 16);
    Port (
      A:    in  std_logic_vector(NBIT-1 downto 0);
      B:    in  std_logic_vector(NBIT-1 downto 0);
      SEL:  in  std_logic;
      Y:    out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  component FD_GEN is
    Generic (NBIT: integer:= 16);
    Port (
      D:    in  std_logic_vector(NBIT-1 downto 0);
      CK:   in  std_logic;
      EN:   in  std_logic;
      RESET:in  std_logic;
      Q:    out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  signal out_A, out_B, alu_out, exe_out_s, mult_out, exe_out_reg, in_fw_a_1, out_fw_b, out_fw_a_0, out_fw_b_0 : std_logic_vector(NBIT-1 downto 0);

begin


  REG_PC_PLUS_4 : FD_GEN
    generic map(NBIT)
    port map (
      D => NPC,
      CK => CLK,
      EN => EN_ALU,
      RESET => RES,
      Q => PC_PLUS_4
    );
 
  -- Instantiate MUX21_GEN for NPC and A signals
  MUX_A_NPC : MUX21_GEN
    generic map(NBIT)
    port map (
      A => A,
      B => NPC,
      SEL => SEL_A,
      Y => in_fw_a_1
    );

  -- Instantiate MUX21_GEN for B and IMM signals
  MUX_B_IMM : MUX21_GEN
    generic map(NBIT)
    port map (
      A => out_fw_b,
      B => IMM,
      SEL => SEL_B,
      Y => out_b
    );

  -- Instantiate ALU component
  ALU_INST  : ALU
    generic map(NBIT, NBIT_PER_BLOCK)
    port map (
      A => out_A,
      B => out_B,
	    SEL_LHI => SEL_LHI,
      MODE => ALU_MODE,
      S => alu_out
    );

  -- Instantiate BOOTHMUL with 32-bit output
  MULT : BOOTHMUL
    generic map(NBIT/2)
    port map (
      A => out_A(NBIT/2 - 1 downto 0),
      B => out_B(NBIT/2 - 1 downto 0),
      P => mult_out
    );

  -- Instantiate MUX21_GEN for ALU output and multiplier output signals
  MUX_EXE : MUX21_GEN
    generic map(NBIT)
    port map (
      A => alu_out,
      B => mult_out,
      SEL => SEL_EXE_TYPE,
      Y => exe_out_s
    );

 -- Instantiate MUX21_GEN for Reg A or alu_out choice
  MUX_JUMP : MUX21_GEN
    generic map(NBIT)
    port map (
      A => alu_out,
      B => out_a,
      SEL => SEL_MUX_JUMP,
      Y => PC_OUT
    );

  -- Instantiate FD_GEN for the execution unit output
  REG_EXE : FD_GEN
    generic map(NBIT)
    port map (
      D => exe_out_s,
      CK => CLK,
      EN => EN_ALU,
      RESET => RES,
      Q => exe_out_reg
    );

  -- Instantiate FD_GEN for the DRAM address
  ME : FD_GEN
    generic map(NBIT)
    port map (
      D => out_fw_b,
      CK => CLK,
      EN => EN_ALU,
      RESET => RES,
      Q => ADDR_DRAM
    );

  -- Instantiate FD_GEN for the RD signal
  RD_REG : FD_GEN
    generic map(5)
    port map (
      D => RD,
      CK => CLK,
      EN => EN_ALU,
      RESET => RES,
      Q => RD_OUT
    );

	-- FORWARDING
  MUX_FW_ALU_MEM_A : MUX21_GEN
    generic map(NBIT)
    port map (
      A => MEM_DATA,
      B => exe_out_reg,
      SEL => SEL_FW_A(0),
      Y => out_fw_a_0
    );

  MUX_FW_FIN_A : MUX21_GEN
    generic map(NBIT)
    port map (
      A => out_fw_a_0,
      B => in_fw_a_1,
      SEL => SEL_FW_A(1),
      Y => out_a
    );

  MUX_FW_ALU_MEM_B : MUX21_GEN
    generic map(NBIT)
    port map (
      A => MEM_DATA,
      B => exe_out_reg,
      SEL => SEL_FW_B(0),
      Y => out_fw_b_0
    );

  MUX_FW_FIN_B : MUX21_GEN
    generic map(NBIT)
    port map (
      A => out_fw_b_0,
      B => B,
      SEL => SEL_FW_B(1),
      Y => out_fw_b
    );

EXE_OUT <= exe_out_reg;

end structural;

