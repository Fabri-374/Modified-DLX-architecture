library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.constants.all;
use work.functions.all;

-- Define the DECODE_UNIT entity with generic and port declarations
entity DECODE_UNIT is
  generic (
    NBIT : integer := 32;             -- Bit width
    OPCODE_SIZE : integer := OPCODE_SIZE  -- Size of the opcode field
  );
  port (
    IR : in  std_logic_vector(NBIT - 1 downto 0);    -- Instruction Register
    NPC : in  std_logic_vector(NBIT - 1 downto 0);   -- Next Program Counter
    DATAIN : in std_logic_vector(NBIT - 1 downto 0); -- Data Input
    ALU_DATA : in std_logic_vector(NBIT - 1 downto 0);-- ALU Data
    SEL : in std_logic_vector(1 downto 0);            -- Select Signal
    EN_D : in std_logic;                               -- Decode Enable
    EN_COND : in std_logic;                            -- Condition Enable
    EN_RF : in std_logic;                              -- Register File Enable
    CLK : in std_logic;                                -- Clock Signal
    RES : in std_logic;                                -- Reset Signal
    RD1: in std_logic;                                 -- Read Data 1
    RD2: in std_logic;                                 -- Read Data 2
    WR: in std_logic;                                  -- Write Signal
    SEL_ADD_WR : in std_logic;                         -- Select Address to Write
    SEL_FW_BRANCH : in std_logic_vector(1 DOWNTO 0);   -- Select Forwarding or Branch
    PC_PLUS_4 : in std_logic_vector(NBIT - 1 downto 0);-- PC Plus 4
    ADDRESS_WRITE : in  std_logic_vector(4 downto 0);  -- Address to Write
    SEL_MUX_PC : out std_logic;                        -- Select Multiplexer for PC
    A : out std_logic_vector(NBIT - 1 downto 0);      -- Output A
    B : out std_logic_vector(NBIT - 1 downto 0);      -- Output B
    IMM : out std_logic_vector(NBIT - 1 downto 0);    -- Output Immediate
    NPC_OUT : out  std_logic_vector(NBIT - 1 downto 0);-- Output NPC
    RD_OUT : out  std_logic_vector(4 downto 0);       -- Output RD
    RS1: out std_logic_vector(4 DOWNTO 0);             -- Output RS1
    RS2: out std_logic_vector(4 DOWNTO 0);             -- Output RS2
    RD: out std_logic_vector(4 DOWNTO 0)               -- Output RD
  );
end DECODE_UNIT;

-- Define the structural architecture for the DECODE_UNIT entity
architecture STRUCTURAL of DECODE_UNIT is
  -- Component declarations
  component FD_GEN is
    Generic (NBIT: integer := 16);
    Port (
      D:    in  std_logic_vector(NBIT-1 downto 0);
      CK:   in  std_logic;
      EN:   in  std_logic;
      RESET:in  std_logic;
      Q:    out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  component COND is	
    generic (NBIT : integer := NumBit;
      OPCODE_SIZE : integer := OPCODE_SIZE);
    Port (
      Y:	In	std_logic;
      OPCODE:	In	std_logic_vector(OPCODE_SIZE-1 downto 0);
      CLK : In	std_logic;
      RES : In	std_logic;
      EN : In	std_logic;
      SEL:	Out	std_logic
    );
  end component;

  component ZERO_DETECTOR is
    generic (N: integer := NumBit);	
    Port (	A:	In	std_logic_vector(N-1 DOWNTO 0);
      Y:	Out	std_logic
    );
  end component;

  component register_file is
    generic(NBIT : integer := NumBit;
      ADDR : integer := Addr_Length);
    port (
      RESET: 	IN std_logic;
      ENABLE: 	IN std_logic;
      RD1: 		IN std_logic;
      RD2: 		IN std_logic;
      WR: 		IN std_logic;
      ADD_WR: 	IN std_logic_vector(ADDR-1 downto 0);
      ADD_RD1: 	IN std_logic_vector(ADDR-1 downto 0);
      ADD_RD2: 	IN std_logic_vector(ADDR-1 downto 0);
      DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
      OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
      OUT2: 		OUT std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  component sign_extend is
    generic (
      NBIT : integer := NumBit;
      IMMEDIATE_LENGTH : integer := IMMEDIATE_LENGTH;
      BRANCHLABEL_LENGTH : integer := BRANCHLABEL_LENGTH
    );
    port (
      DATAIN_16:   in  std_logic_vector(IMMEDIATE_LENGTH-1 downto 0);
      DATAIN_26:   in  std_logic_vector(BRANCHLABEL_LENGTH-1 downto 0);
      DATAOUT_16U: out std_logic_vector(NBIT-1 downto 0);
      DATAOUT_16S: out std_logic_vector(NBIT-1 downto 0);
      DATAOUT_26U: out std_logic_vector(NBIT-1 downto 0);
      DATAOUT_26S: out std_logic_vector(NBIT-1 downto 0)
    );
  end component;

  component IR_decoder is
    GENERIC (N: integer := NumBit);
    PORT (
      IR_IN:   IN  std_logic_vector(N -1 downto 0);
      RS1:     OUT std_logic_vector(4 DOWNTO 0);
      RS2:     OUT std_logic_vector(4 DOWNTO 0);
      RD:      OUT std_logic_vector(4 DOWNTO 0);
      imm16:   OUT std_logic_vector(15 DOWNTO 0);
      imm26:   OUT std_logic_vector(25 DOWNTO 0)
    );
  end component;

  component MUX41_GEN is
    Generic (NBIT: integer:= 16);
    Port (
      A:    IN  std_logic_vector(NBIT-1 downto 0);
      B:    IN  std_logic_vector(NBIT-1 downto 0);
      C:    IN  std_logic_vector(NBIT-1 downto 0);
      D:    IN  std_logic_vector(NBIT-1 downto 0);
      Sel:  IN  std_logic_vector(1 downto 0);
      Y:    OUT std_logic_vector(NBIT-1 downto 0)
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

  -- Signal declaration area
  signal zero_cond, not_stall, reset_rd: std_logic;
  signal rs1_s, rs2_s, rd_s: std_logic_vector(4 downto 0);
  signal imm16_s: std_logic_vector(15 DOWNTO 0);
  signal imm26_s: std_logic_vector(25 DOWNTO 0);
  signal imm16_s_u, imm16_s_s, imm26_s_u, imm26_s_s, out1, out2, outmux, data_write, zero_in, out_branch_0 : std_logic_vector(NBIT-1 downto 0);

begin
  -- Logic for output signals and component instantiation
  not_stall <= not EN_COND;
  reset_rd <= RES or EN_COND;
  RS1 <= rs1_s;
  RS2 <= rs2_s;
  RD <= rd_s;

  -- Instantiate zero detector module
  Z_DET: ZERO_DETECTOR
    generic map (NBIT)
    port map (
      A => zero_in,
      Y => zero_cond
    );

  -- Instantiate cond module
  COND_SEL: COND
    port map (
      OPCODE => IR(NBIT-1 downto NBIT-OPCODE_SIZE),
      Y => zero_cond,
      CLK => CLK,
      RES => RES,
      EN => not_stall,
      SEL => SEL_MUX_PC
    );

  -- Instantiate IR_decoder module
  IR_DEC: IR_decoder
    generic map (NBIT)
    port map (
      IR_IN => IR,
      RS1 => rs1_s,
      RS2 => rs2_s,
      RD => rd_s,
      imm16 => imm16_s,
      imm26 => imm26_s
    );

  -- Instantiate sign_extend module
  SIGN_EXT: sign_extend
    generic map (
      NBIT,
      IMMEDIATE_LENGTH,
      BRANCHLABEL_LENGTH
    )
    port map (
      DATAIN_16 => imm16_s,
      DATAIN_26 => imm26_s,
      DATAOUT_16U => imm16_s_u,
      DATAOUT_16S => imm16_s_s,
      DATAOUT_26U => imm26_s_u,
      DATAOUT_26S => imm26_s_s
    );

  -- Instantiate MUX41_GEN module
  MUX: MUX41_GEN
    generic map (NBIT)
    port map (
      A => imm16_s_u,
      B => imm16_s_s,
      C => imm26_s_u,
      D => imm26_s_s,
      Sel => SEL,
      Y => outmux
    );

  -- Instantiate register file module
  REG_FILE: register_file
    port map (
      RESET => RES,
      ENABLE => EN_RF,
      RD1 => RD1,
      RD2 => RD2,
      WR => WR,
      ADD_WR => ADDRESS_WRITE,
      ADD_RD1 => rs1_s,
      ADD_RD2 => rs2_s,
      DATAIN => data_write,
      OUT1 => out1,
      OUT2 => out2
    );

  -- Instantiate NPC_REG module
  NPC_REG: FD_GEN
    generic map (NBIT)
    port map (
      D => NPC,
      CK => CLK,
      EN => EN_D,
      RESET => RES,
      Q => NPC_OUT
    );

  -- Instantiate A_REG module
  A_REG: FD_GEN
    generic map (NBIT)
    port map (
      D => out1,
      CK => CLK,
      EN => EN_D,
      RESET => RES,
      Q => A
    );

  -- Instantiate B_REG module
  B_REG: FD_GEN
    generic map (NBIT)
    port map (
      D => out2,
      CK => CLK,
      EN => EN_D,
      RESET => RES,
      Q => B
    );

  -- Instantiate IMM_REG module
  IMM_REG: FD_GEN
    generic map (NBIT)
    port map (
      D => outmux,
      CK => CLK,
      EN => EN_D,
      RESET => RES,
      Q => IMM
    );

  -- Instantiate RD_REG module
  RD_REG: FD_GEN
    generic map (5)
    port map (
      D => rd_s,
      CK => CLK,
      EN => EN_D,
      RESET => reset_rd,
      Q => RD_OUT
    );

  -- Mux used to choose which data writing into the RF
  MUX_DATA_WR : MUX21_GEN
    generic map(NBIT)
    port map (
      A => PC_PLUS_4,
      B => DATAIN,
      SEL => SEL_ADD_WR,
      Y => data_write
    );

  -- Mux for branch forwarding 
  MUX_FW_0 : MUX21_GEN
    generic map(NBIT)
    port map (
      A => DATAIN,
      B => ALU_DATA,
      SEL => SEL_FW_BRANCH(0),
      Y => out_branch_0
    );

  -- Mux for branch forwarding 
  MUX_FW_1 : MUX21_GEN
    generic map(NBIT)
    port map (
      A => out_branch_0,
      B => out1,
      SEL => SEL_FW_BRANCH(1),
      Y => zero_in
    );

end STRUCTURAL;
