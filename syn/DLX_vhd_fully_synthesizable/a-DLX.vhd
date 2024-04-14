library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.constants.all;
use work.functions.all;

entity DLX is
  generic (NBIT : integer := NumBit;
	   	NBIT_PER_BLOCK : integer := NBIT_PER_BLOCK;
    	I_SIZE : integer := I_SIZE;
    	WORD_SIZE : integer := NumBit
);
  port (
    CLK : in std_logic;
    RES : in std_logic;

    Addr_iram : out  std_logic_vector(I_SIZE - 1 downto 0);
    Dout_iram : in std_logic_vector(I_SIZE - 1 downto 0);

	ADDR_dram : out  std_logic_vector(WORD_SIZE-1 downto 0);  		-- Address input
    DATA_IN_dram :  out std_logic_vector(WORD_SIZE-1 downto 0);  	-- Data input for write
    DATA_OUT_dram : in std_logic_vector(WORD_SIZE - 1 downto 0);  	-- Data output for read
    SEL_dram: out std_logic_vector(2 downto 0);  			-- Selector for different data width reads/writes
    RM_dram: out std_logic;  											-- Read enable
    WM_dram: out std_logic;  											-- Write enable
    EN_dram: out std_logic;  											-- Enable signal
    );
end DLX;

architecture STRUCTURAL of DLX is

component DATAPATH is
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
	-- hazard_unit
    OP_TYPE_HAZARD : in std_logic_vector(1 downto 0);
    STALL : out std_logic;   
	-- forwarding 
    OP_TYPE_FORWARD : in std_logic_vector(1 downto 0)
    );
end component;

-- CONTROL UNIT INST
component CU_HW is
       port (
              -- INPUTS
	IR_IN : in std_logic_vector(I_SIZE - 1 downto 0);
    Clk : in std_logic;
    Rst : in std_logic;          
	STALL: in std_logic;
    FLUSH : in std_logic;

	-- FETCH CONTROL SIGNALS
	EN_FETCH : out std_logic;

	-- DECODE CONTROL SIGNALS
	SEL_SIGN_DECODE : out std_logic_vector(1 downto 0);
    EN_DECODE : out std_logic;
    EN_RF : out std_logic;
    RD1_EN_RF : out std_logic;
    RD2_EN_RF : out std_logic;

	-- EXECUTION CONTROL SIGNALS
    SEL_A_EXE : out std_logic;
    SEL_B_EXE : out std_logic;
    EN_ALU_EXE : out std_logic;
    SEL_MUX_JUMP_ALU_REGA : out std_logic;
    SEL_LHI : out std_logic;

    SEL_EXE_UNIT_TYPE : out std_logic; -- passare dopo
    ALU_MODE : out std_logic_vector(5 downto 0);-- passare dopo

   	-- MEMORY CONTROL SIGNALS
    EN_LMD_MEM : out std_logic;
    SEL: out std_logic_vector(2 downto 0);  -- Selector for different data width reads/writes
    RM: out std_logic;  -- Read enable
    WM: out std_logic;  -- Write enable
    EN: out std_logic;  -- Enable signal

	-- WRITE BACK STAGE
	SEL_WB : out std_logic;
	WR_EN_RF : out std_logic;
	SEL_ADD_WR : out std_logic;
	EN_PC : out std_logic;

	-- HAZARD UNIT
    OP_TYPE_HAZARD : out std_logic_vector(1 downto 0); -- exe stage

	--FORWARD UNIT
    OP_TYPE_FORWARD : out std_logic_vector(1 downto 0) -- uno in mem e l'altro in wb
	);
 end component;

-- DRAM signals
signal RM_signal, WM_signal, EN_signal : std_logic;
signal SEL_signal : std_logic_vector(2 downto 0);

-- Common signals
signal STALL_signal, EN_RF_signal, sel_lhi : std_logic;

-- CU_HW signals
signal EN_FETCH_signal, FLUSH_signal : std_logic;
signal SEL_SIGN_DECODE_signal: std_logic_vector(1 downto 0);
signal EN_DECODE_signal, RD1_EN_RF_signal, RD2_EN_RF_signal, WR_EN_RF_signal : std_logic;
signal EN_ALU_EXE_signal, SEL_MUX_JUMP_ALU_REGA_signal, SEL_EXE_UNIT_TYPE_signal : std_logic;
signal ALU_MODE_signal : std_logic_vector(5 downto 0);
signal EN_LMD_MEM_signal,SEL_A_EXE_signal, SEL_B_EXE_signal  : std_logic;
signal DATAIN_DRAM_signal, DATAOUT_DRAM_signal, ADDR_DRAM_signal : std_logic_vector(NBIT - 1 downto 0);
signal SEL_WB_signal : std_logic;
signal SEL_ADD_WR_signal, EN_PC_signal : std_logic;
signal OP_TYPE_FORWARD_signal, OP_TYPE_HAZARD_signal: std_logic_vector(1 downto 0);

-- DATAPATH signals
signal DOUT_IRAM_signal, ADDR_IRAM_signal : std_logic_vector(NBIT - 1 downto 0);

begin

    ADDR_dram <= ADDR_DRAM_signal;
    DATA_IN_dram <= DATAIN_DRAM_signal;
    SEL_dram <= SEL_signal;
    RM_dram <= RM_signal;
    WM_dram <= WM_signal;
    EN_dram <= EN_signal;
	DATAOUT_DRAM_signal <= DATA_OUT_dram;
    

	Addr_iram <= ADDR_IRAM_signal;
    DOUT_IRAM_signal <= Dout_iram;

datapath_inst : DATAPATH
generic map (
    NBIT => NumBit,
    NBIT_PER_BLOCK => NBIT_PER_BLOCK
)
port map (
    -- Fetch
    CLK => CLK,
    RES => RES,
    EN_PC => EN_PC_signal,
    EN_FETCH => EN_FETCH_signal,
    DOUT_IRAM => DOUT_IRAM_signal,
    ADDR_IRAM => ADDR_IRAM_signal,
    -- Decode
    SEL_SIGN_DECODE => SEL_SIGN_DECODE_signal,
    EN_DECODE => EN_DECODE_signal,
    EN_RF => EN_RF_signal,
    RD1_EN_RF => RD1_EN_RF_signal,
    RD2_EN_RF => RD2_EN_RF_signal,
    WR_EN_RF => WR_EN_RF_signal,
    SEL_ADD_WR => SEL_ADD_WR_signal,
    FLUSH => FLUSH_signal,
    -- Execution
    SEL_A_EXE => SEL_A_EXE_signal,
    SEL_B_EXE => SEL_B_EXE_signal,
    SEL_EXE_UNIT_TYPE => SEL_EXE_UNIT_TYPE_signal,
    SEL_LHI => sel_lhi,
    ALU_MODE => ALU_MODE_signal,
    EN_ALU_EXE => EN_ALU_EXE_signal,
    SEL_MUX_JUMP_ALU_REGA => SEL_MUX_JUMP_ALU_REGA_signal,
    ADDR_DRAM => ADDR_DRAM_signal,
    DATAIN_DRAM => DATAIN_DRAM_signal,
    -- Memory
    EN_LMD_MEM => EN_LMD_MEM_signal,
    DATAOUT_DRAM => DATAOUT_DRAM_signal,
    -- Write Back
    SEL_WB => SEL_WB_signal,
    -- hazard_unit
    OP_TYPE_HAZARD => OP_TYPE_HAZARD_signal,
    STALL => STALL_signal,
    -- forwarding 
    OP_TYPE_FORWARD => OP_TYPE_FORWARD_signal
);

cu_hw_inst : CU_HW
port map (
IR_IN => DOUT_IRAM_signal,
Clk => CLK,
Rst => RES,
STALL => STALL_signal,
FLUSH => FLUSH_signal,
EN_FETCH => EN_FETCH_signal,
SEL_SIGN_DECODE => SEL_SIGN_DECODE_signal,
EN_DECODE => EN_DECODE_signal,
EN_RF => EN_RF_signal,
RD1_EN_RF => RD1_EN_RF_signal,
RD2_EN_RF => RD2_EN_RF_signal,
SEL_A_EXE => SEL_A_EXE_signal,
SEL_B_EXE => SEL_B_EXE_signal,
EN_ALU_EXE => EN_ALU_EXE_signal,
SEL_MUX_JUMP_ALU_REGA => SEL_MUX_JUMP_ALU_REGA_signal,
SEL_LHI => sel_lhi,
SEL_EXE_UNIT_TYPE => SEL_EXE_UNIT_TYPE_signal,
ALU_MODE => ALU_MODE_signal,
EN_LMD_MEM => EN_LMD_MEM_signal,
SEL => SEL_signal,
RM => RM_signal,
WM => WM_signal,
EN => EN_signal,
SEL_WB => SEL_WB_signal,
WR_EN_RF => WR_EN_RF_signal,
SEL_ADD_WR => SEL_ADD_WR_signal,
EN_PC => EN_PC_signal,
OP_TYPE_HAZARD => OP_TYPE_HAZARD_signal,
OP_TYPE_FORWARD => OP_TYPE_FORWARD_signal
);

end architecture STRUCTURAL;

