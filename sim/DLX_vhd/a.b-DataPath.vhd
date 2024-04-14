library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.constants.all;
use work.functions.all;

entity DATAPATH is
  generic (NBIT : integer := NumBit;
	   NBIT_PER_BLOCK : integer := NBIT_PER_BLOCK
);
  port (
	  -- Fetch
    CLK : in std_logic;
    RES : in std_logic;
    EN_PC : in std_logic;
    EN_FETCH : in std_logic;
    DOUT_IRAM : in std_logic_vector(NBIT - 1 downto 0);
    ADDR_IRAM : out  std_logic_vector(NBIT - 1 downto 0);

	  -- Decode
    SEL_SIGN_DECODE : in std_logic_vector(1 downto 0);
    EN_DECODE : in std_logic;
    EN_RF : in std_logic;
    RD1_EN_RF : in std_logic;
    RD2_EN_RF : in std_logic;
    WR_EN_RF : in std_logic;
    SEL_ADD_WR : in std_logic;
    FLUSH : out std_logic;

	  -- Execution
    SEL_A_EXE : in std_logic;
    SEL_B_EXE : in std_logic;
    SEL_EXE_UNIT_TYPE : in std_logic;
    SEL_LHI : in std_logic;
    ALU_MODE : in std_logic_vector(5 downto 0);
    EN_ALU_EXE : in std_logic;
    SEL_MUX_JUMP_ALU_REGA : in std_logic;
    ADDR_DRAM : out std_logic_vector(NBIT-1 downto 0);
    DATAIN_DRAM : out std_logic_vector(NBIT-1 downto 0);

	  -- Memory
    EN_LMD_MEM : in std_logic;
    DATAOUT_DRAM : in std_logic_vector(NBIT-1 downto 0);

	  -- Write Back
    SEL_WB : in std_logic;

	  -- Hazard unit
    OP_TYPE_HAZARD : in std_logic_vector(1 downto 0);
    STALL : out std_logic;   

	  -- Forwarding unit
    OP_TYPE_FORWARD : in std_logic_vector(1 downto 0)
    );
end DATAPATH;

architecture STRUCTURAL of DATAPATH is

component FETCH_UNIT is
  generic (
    I_SIZE : integer := 32);
  port (
    DOUT : in std_logic_vector(I_SIZE - 1 downto 0);
    PC : in std_logic_vector(I_SIZE - 1 downto 0);
    EN_PC : in std_logic;
    EN_F : in std_logic;
    SEL_BRANCH : in std_logic;
    CLK : in std_logic;
    RES : in std_logic;
    ADDR : out  std_logic_vector(I_SIZE - 1 downto 0);
    NPC : out  std_logic_vector(I_SIZE - 1 downto 0);
    IR : out  std_logic_vector(I_SIZE - 1 downto 0)
    );
end component;

component DECODE_UNIT is
  generic (NBIT : integer := 32;
	OPCODE_SIZE : integer := OPCODE_SIZE);
  port (
    IR : in  std_logic_vector(NBIT - 1 downto 0);
    NPC : in  std_logic_vector(NBIT - 1 downto 0);
    DATAIN : in std_logic_vector(NBIT - 1 downto 0);
    ALU_DATA : in std_logic_vector(NBIT - 1 downto 0);
    SEL : in std_logic_vector(1 downto 0);
    EN_D : in std_logic;
    EN_COND : in std_logic;
    EN_RF : in std_logic;
    CLK : in std_logic;
    RES : in std_logic;
    RD1: in std_logic;
    RD2: in std_logic;
    WR: in std_logic;
    SEL_ADD_WR : in std_logic;
    SEL_FW_BRANCH : in std_logic_vector(1 DOWNTO 0);
    PC_PLUS_4 : in std_logic_vector(NBIT - 1 downto 0);
    ADDRESS_WRITE : in  std_logic_vector(4 downto 0);
    SEL_MUX_PC : out std_logic;
    A : out std_logic_vector(NBIT - 1 downto 0);
    B : out std_logic_vector(NBIT - 1 downto 0);
    IMM : out std_logic_vector(NBIT - 1 downto 0);
    NPC_OUT : out  std_logic_vector(NBIT - 1 downto 0);
    RD_OUT : out  std_logic_vector(4 downto 0);
    RS1: out std_logic_vector(4 DOWNTO 0);
    RS2: out std_logic_vector(4 DOWNTO 0);
    RD: out std_logic_vector(4 DOWNTO 0)
  );
end component;

component Execution_unit is
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
end component;

component memory_unit is
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
end component;

component write_back_unit is
  generic (
    NBIT : integer := NumBit
  );
  port (
    LMD : in std_logic_vector(NBIT-1 downto 0);  -- Input: Next Program Counter
    ALU_DATA : in std_logic_vector(NBIT-1 downto 0);
    SEL : in std_logic;
    DATA_OUT : out std_logic_vector(NBIT-1 downto 0)
  );
end component;

component HAZARD_UNIT is
    GENERIC (NBIT: integer := ADD_RF_LENGTH);
    PORT(   CLK : IN std_logic;
             RES : IN std_logic;
             OP_TYPE: IN std_logic_vector(1 downto 0); -- MSB BRANCH, LSB LOAD
             RS1: IN std_logic_vector(NBIT-1 DOWNTO 0);
             RS2: IN std_logic_vector(NBIT-1 DOWNTO 0);
             RD: IN std_logic_vector(NBIT-1 DOWNTO 0);
             STALL : OUT std_logic
    );
end component;

component FORWARDING_UNIT is
    GENERIC (NBIT: integer := ADD_RF_LENGTH);
    PORT(CLK : IN std_logic;
         RST : IN std_logic;
         FLUSH : IN std_logic;
	       STALL : IN std_logic;
         OP_TYPE: IN std_logic_vector(1 downto 0); -- MSB MEM, LSB ALU
         RS1: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RS2: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RD1: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RD2: IN std_logic_vector(NBIT-1 DOWNTO 0);
         SEL_FW_A: OUT std_logic_vector(1 DOWNTO 0);
         SEL_FW_B: OUT std_logic_vector(1 DOWNTO 0);
         SEL_FW_BRANCH : OUT std_logic_vector(1 DOWNTO 0)
    );
end component;

--signals declaration area
-- fetch - decode
signal s_npc_fetch_decode, s_ir_fetch_decode : std_logic_vector(NBIT-1 downto 0);
-- decode - execution
signal s_a_decode_execution, s_b_decode_execution, s_imm_decode_execution, s_npc_decode_execution: std_logic_vector(NBIT-1 downto 0);
signal s_rf_address_write, s_rd_decode_execution, s_rd_decode, s_rs1_decode, s_rs2_decode: std_logic_vector(4 downto 0);
signal s_sel_mux_pc_cond_out, stall_signal : std_logic;
-- execution - memory
signal s_pc_plus_4_execution_memory, s_alu_execution_memory : std_logic_vector(NBIT-1 downto 0);
signal s_rd_execution_memory: std_logic_vector(4 downto 0);
-- memory - write back
signal s_lmd_memory_wb, s_alu_data_memory_wb : std_logic_vector(NBIT-1 downto 0);
-- others
signal s_data_out_wb, s_pc_plus_4_memory, s_pc_execution : std_logic_vector(NBIT-1 downto 0);
-- forwarding control signals
signal sel_fw_a, sel_fw_b, sel_fw_branch : std_logic_vector(1 downto 0);


begin

  FLUSH <= s_sel_mux_pc_cond_out;
  ADDR_DRAM <= s_alu_execution_memory;
  STALL <= stall_signal;

  -- Port Map for FETCH_UNIT Component
  FETCH_UNIT_inst : FETCH_UNIT
    generic map (
      I_SIZE => NumBit
    )
    port map (
      DOUT => DOUT_IRAM,
      PC => s_pc_execution,
      EN_PC => EN_PC,
      EN_F => EN_FETCH,
      SEL_BRANCH => s_sel_mux_pc_cond_out,
      CLK => CLK,
      RES => RES,
      ADDR => ADDR_IRAM,
      NPC => s_npc_fetch_decode,
      IR => s_ir_fetch_decode
  );

  -- Port Map for DECODE_UNIT Component
  DECODE_UNIT_inst : DECODE_UNIT
    generic map (
        NBIT => NumBit,
        OPCODE_SIZE => OPCODE_SIZE
    )
    port map (
      IR => s_ir_fetch_decode,
      NPC => s_npc_fetch_decode,
      DATAIN => s_data_out_wb,
      ALU_DATA => s_alu_execution_memory,
      SEL => SEL_SIGN_DECODE,
      EN_D => EN_DECODE,
      EN_COND => stall_signal,
      EN_RF => EN_RF,
      CLK => CLK,
      RES => RES,
      RD1 => RD1_EN_RF,
      RD2 => RD2_EN_RF,
      WR => WR_EN_RF,
      SEL_ADD_WR => SEL_ADD_WR,
      SEL_FW_BRANCH => sel_fw_branch,
      PC_PLUS_4 => s_pc_plus_4_memory,
      ADDRESS_WRITE => s_rf_address_write,
      SEL_MUX_PC => s_sel_mux_pc_cond_out,
      A => s_a_decode_execution,
      B => s_b_decode_execution,
      IMM => s_imm_decode_execution,
      NPC_OUT => s_npc_decode_execution,
      RD_OUT => s_rd_decode_execution,
      RS1 => s_rs1_decode,
      RS2 => s_rs2_decode,
      RD => s_rd_decode 
  );

  -- Port Map for Execution_unit Component
  Execution_unit_inst : Execution_unit
      generic map (
          NBIT => NumBit,
          NBIT_PER_BLOCK => NBIT_PER_BLOCK
      )
      port map (
          NPC => s_npc_decode_execution,
          A => s_a_decode_execution,
          B => s_b_decode_execution,
          IMM => s_imm_decode_execution,
          SEL_A => SEL_A_EXE,
          SEL_B => SEL_B_EXE,
          SEL_EXE_TYPE => SEL_EXE_UNIT_TYPE,
          ALU_MODE => ALU_MODE,
          EN_ALU => EN_ALU_EXE,
          CLK => CLK,
          RES => RES,
          RD => s_rd_decode_execution,
          SEL_MUX_JUMP => SEL_MUX_JUMP_ALU_REGA,
          SEL_LHI => SEL_LHI,
          SEL_FW_A => sel_fw_a,
          SEL_FW_B => sel_fw_b,
          MEM_DATA => s_data_out_wb,
          ADDR_DRAM => DATAIN_DRAM,
          RD_OUT => s_rd_execution_memory,
          EXE_OUT => s_alu_execution_memory,
          PC_PLUS_4 => s_pc_plus_4_execution_memory,
          PC_OUT => s_pc_execution
      );


  -- Port Map for memory_unit Component
  memory_unit_inst : memory_unit
      generic map (
          NBIT => NumBit
      )
      port map (
          PC_PLUS_4 => s_pc_plus_4_execution_memory,
          EN_LMD => EN_LMD_MEM,
          CLK => CLK,
          RES => RES,
          RD => s_rd_execution_memory,
          DRAM_DATA => DATAOUT_DRAM,
          ALU_DATA => s_alu_execution_memory,
          RD_OUT => s_rf_address_write,
          LMD => s_lmd_memory_wb,
          PC_PLUS_4_OUT => s_pc_plus_4_memory,
          ALU_DATA_OUT => s_alu_data_memory_wb
      );

  -- Port Map for write_back_unit Component
  write_back_unit_inst : write_back_unit
    generic map (
      NBIT => NumBit
    )
    port map (
      LMD => s_lmd_memory_wb,
      ALU_DATA => s_alu_data_memory_wb,
      SEL => SEL_WB,
      DATA_OUT => s_data_out_wb
    );

  -- Port map for hazard unit
  hazard_unit_inst : HAZARD_UNIT
      generic map (
          NBIT => ADD_RF_LENGTH
      )
      port map (
          CLK => CLK,
          RES => RES,
          OP_TYPE => OP_TYPE_HAZARD,
          RS1 => s_rs1_decode,
          RS2 => s_rs2_decode,
          RD => s_rd_decode,
          STALL => stall_signal
      );

  -- Port map for forwarding unit
  forwarding_unit_inst : FORWARDING_UNIT
      generic map (
          NBIT => ADD_RF_LENGTH
      )
      port map (
          CLK => CLK,
          RST => RES,
          FLUSH => s_sel_mux_pc_cond_out,
          STALL => stall_signal,
          OP_TYPE => OP_TYPE_FORWARD,
          RS1 => s_rs1_decode,
          RS2 => s_rs2_decode,
          RD1 => s_rd_decode_execution,
          RD2 => s_rd_execution_memory,
          SEL_FW_A => sel_fw_a,
          SEL_FW_B => sel_fw_b,
          SEL_FW_BRANCH => sel_fw_branch
      );
      
end structural;
