library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

-- Define the entity CU_HW with its input and output ports
ENTITY CU_HW IS
    PORT (
        -- INPUTS
        IR_IN : IN std_logic_vector(I_SIZE - 1 downto 0);  -- IR Input
        Clk : IN std_logic;                                  -- Clock Signal
        Rst : IN std_logic;                                  -- Reset Signal
        STALL : IN std_logic;                                -- Stall Signal
        FLUSH : IN std_logic;                                -- Flush Signal

        -- FETCH CONTROL SIGNALS
        EN_FETCH : OUT std_logic;                            -- Enable Fetch Stage

        -- DECODE CONTROL SIGNALS
        SEL_SIGN_DECODE : OUT std_logic_vector(1 downto 0);  -- Select Sign Decode
        EN_DECODE : OUT std_logic;                           -- Enable Decode Stage
        EN_RF : OUT std_logic;                               -- Enable Register File
        RD1_EN_RF : OUT std_logic;                           -- Enable Register File Read Port 1
        RD2_EN_RF : OUT std_logic;                           -- Enable Register File Read Port 2

        -- EXECUTION CONTROL SIGNALS
        SEL_A_EXE : OUT std_logic;                          -- Selection of Operand A in Execution Stage
        SEL_B_EXE : OUT std_logic;                          -- Selection of Operand B in Execution Stage
        EN_ALU_EXE : OUT std_logic;                         -- Enable ALU in Execution Stage
        SEL_MUX_JUMP_ALU_REGA : OUT std_logic;              -- Select ALU or Register A in Mux Jump 
        SEL_LHI : OUT std_logic;                            -- Select LHI Operation

        SEL_EXE_UNIT_TYPE : OUT std_logic;                  -- Select Execution Unit Type
        ALU_MODE : OUT std_logic_vector(5 downto 0);        -- ALU Mode

        -- MEMORY CONTROL SIGNALS
        EN_LMD_MEM : OUT std_logic;                        -- Enable Load Memory Data in Memory Stage
        SEL : OUT std_logic_vector(2 downto 0);            -- Selector for Different Data Width Reads/Writes
        RM : OUT std_logic;                                -- Read Enable Memory
        WM : OUT std_logic;                                -- Write Enable Memory
        EN : OUT std_logic;                                -- Enable of the Memory

        -- WRITE BACK STAGE
        SEL_WB : OUT std_logic;                            -- Select Write Back Stage
        WR_EN_RF : OUT std_logic;                          -- Enable Register File Write Back
        SEL_ADD_WR : OUT std_logic;                        -- Select Address Write
        EN_PC : OUT std_logic;                             -- Enable Program Counter

        -- HAZARD UNIT
        OP_TYPE_HAZARD : OUT std_logic_vector(1 downto 0);  -- Operand Type Hazard 

        -- FORWARD UNIT
        OP_TYPE_FORWARD : OUT std_logic_vector(1 downto 0)  -- Operand Type Forward
    );
END CU_HW;

-- Define the architecture MIXED for the CU_HW entity
ARCHITECTURE MIXED OF CU_HW IS
	
    -- Declare signals used in the architecture
    SIGNAL opcode : std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    SIGNAL func : std_logic_vector(5 downto 0);    
    SIGNAL en_rf_decode, en_rf_wb : std_logic;

    -- Signals for control words in different pipeline stages
    SIGNAL cw_fet : std_logic_vector(CW_SIZE -1 downto 0);  -- Fetch stage and following
    SIGNAL cw_dec : std_logic_vector(CW_SIZE - 1 - 2 downto 0);  -- Decode stage and following
    SIGNAL cw_exe : std_logic_vector(CW_SIZE - 1 - 2 - 9 downto 0);  -- Execution and following
    SIGNAL cw_mem : std_logic_vector(CW_SIZE - 1 - 2 - 9 - 5 downto 0);  -- Memory and following
    SIGNAL cw_wb : std_logic_vector(CW_SIZE - 1 - 2 - 9 - 5 - 7 downto 0);  -- Write back and following

    -- Signals for ALU operation codes and selectors
    SIGNAL aluOpcode_i: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP; 
    SIGNAL aluOpcode1: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP;
    SIGNAL aluopcode2: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP;
    SIGNAL sel_exe, sel_exe1, sel_exe2: std_logic;

    -- Constant opcode with all bits set to zero
    CONSTANT zero_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0) := (OTHERS => '0');

BEGIN
    -- Extract the function and opcode from the input instruction
    func <= IR_IN(5 DOWNTO 0);
    opcode <= IR_IN(I_SIZE-1 DOWNTO I_SIZE-OP_CODE_SIZE);

    -- Process to assign control words based on opcode, flush, and stall signals
    CW_ASSEGNATION: PROCESS(OPCODE, FLUSH, STALL)
    BEGIN
        IF (STALL = '1') THEN 
            cw_fet <= cw_fet AND "011111111111111111110111111";  -- Set some bits to zero
        ELSIF (FLUSH = '1') THEN  
            cw_fet <= cw(21); -- NOP -- Allow the program counter to advance
        ELSE
            cw_fet <= cw(CONV_INTEGER(OPCODE));  -- Assign control word based on opcode
        END IF;
    END PROCESS CW_ASSEGNATION;

    -- Assign control signals for the fetch stage
    EN_FETCH <= cw_fet(CW_SIZE - 1);
    EN_PC <= cw_fet(CW_SIZE-21);

    -- Assign control signals for the decode stage
    SEL_SIGN_DECODE <= cw_dec(CW_SIZE-3 DOWNTO CW_SIZE-4);
    EN_DECODE <= cw_dec(CW_SIZE-5) WHEN STALL = '0' ELSE '0';
    en_rf_decode <= cw_dec(CW_SIZE-26);
    EN_RF <= en_rf_decode OR en_rf_wb; 
    RD1_EN_RF <= cw_dec(CW_SIZE-6);
    RD2_EN_RF <= cw_dec(CW_SIZE-7);
    OP_TYPE_HAZARD <= cw_dec(CW_SIZE-22 DOWNTO CW_SIZE-23);
    OP_TYPE_FORWARD <= cw_dec(CW_SIZE-24 DOWNTO CW_SIZE-25);

    -- Assign control signals for the execution stage
    SEL_A_EXE <= cw_exe(CW_SIZE-12);
    SEL_B_EXE <= cw_exe(CW_SIZE-13);
    EN_ALU_EXE <= cw_exe(CW_SIZE-14);
    SEL_MUX_JUMP_ALU_REGA <= cw_exe(CW_SIZE-15);
    SEL_LHI <= cw_exe(CW_SIZE-27);

    -- Assign control signals for the memory stage
    EN_LMD_MEM <= cw_mem(CW_SIZE-17);
    SEL <= cw_mem(CW_SIZE-18 DOWNTO CW_SIZE-20);
    RM <= cw_mem(CW_SIZE-21);
    WM <= cw_mem(CW_SIZE-22);
    EN <= cw_mem(CW_SIZE-23);

    -- Assign control signals for the write back stage
    SEL_WB <= cw_wb(CW_SIZE-24);
    en_rf_wb <= cw_wb(CW_SIZE-27);
    WR_EN_RF <= cw_wb(CW_SIZE-25);
    SEL_ADD_WR <= cw_wb(CW_SIZE-26);

    -- Process for pipeline control words
    CW_PIPE: PROCESS (Clk, Rst)
    BEGIN  
        IF Rst = '1' THEN                   -- Asynchronous reset
            cw_dec <= (OTHERS => '0');
            cw_exe <= (OTHERS => '0');
            cw_mem <= (OTHERS => '0');
            cw_wb <= (OTHERS => '0');
            aluOpcode2 <= TYPE_NOP;
            aluOpcode1 <= TYPE_NOP;
            sel_exe2 <= '1';
            sel_exe1 <= '1';
        ELSIF Clk'EVENT AND Clk = '1' THEN  -- Synchronous normal behavior (without reset)
            IF (FLUSH = '1') THEN 
                cw_dec <= ("0010000000000000000000000"); -- Enable DECODE stage, otherwise, FLUSH remains active forever
                cw_exe <= (OTHERS => '0');
                aluOpcode2 <= aluOpcode1;
                aluOpcode1 <= aluOpcode_i;
                sel_exe2 <= sel_exe1;
                sel_exe1 <= sel_exe;
            ELSIF (STALL = '1') THEN
                cw_exe <= "0010100000000000";  -- Stall the execution stage
                aluOpcode2 <= aluOpcode2;
                aluOpcode1 <= aluOpcode1;
                sel_exe2 <= sel_exe2;
                sel_exe1 <= sel_exe1;
            ELSE 
                cw_dec <= cw_fet(CW_SIZE-2 DOWNTO CW_SIZE-20) & cw_fet(CW_SIZE-22 DOWNTO 0);
                cw_exe <= cw_dec(CW_SIZE-8 DOWNTO CW_SIZE-21) & cw_dec(CW_SIZE-26 DOWNTO CW_SIZE-27);
                aluOpcode2 <= aluOpcode1;
                aluOpcode1 <= aluOpcode_i;
                sel_exe2 <= sel_exe1;
                sel_exe1 <= sel_exe;
            END IF;
            cw_mem <= cw_exe(CW_SIZE-16 DOWNTO 1);
            cw_wb <= cw_mem(CW_SIZE-24 DOWNTO 0);
        END IF;
    END PROCESS CW_PIPE;

    -- Assign Execution Unit Type and ALU Mode signals
    SEL_EXE_UNIT_TYPE <= sel_exe2;
    ALU_MODE <= aluOpcode2;

	-- combinational generation of control alu signals --
	ALU_OP_CODE_P : process (OPCODE, FUNC)
	begin  -- process ALU_OP_CODE_P
		case conv_integer(unsigned(OPCODE)) is
				-- case of R type requires analysis of FUNC --
			when 0 =>
				case conv_integer(unsigned(FUNC)) is
					when 4 => aluOpcode_i <= TYPE_SLL; -- SLL
						sel_exe <= '1';
					when 6 => aluOpcode_i <= TYPE_SRL; -- SRL
						sel_exe <= '1';
					when 7 => aluOpcode_i <= TYPE_SRA; -- SRA
						sel_exe <= '1';
					when 32 => aluOpcode_i <= TYPE_ADD; -- ADD
						sel_exe <= '1';
					when 33 => aluOpcode_i <= TYPE_ADD; -- ADDU
						sel_exe <= '1';
					when 34 => aluOpcode_i <= TYPE_SUB; -- SUB
						sel_exe <= '1';
					when 35 => aluOpcode_i <= TYPE_SUB; -- SUBU
						sel_exe <= '1';
					when 36 => aluOpcode_i <= TYPE_AND; -- AND
						sel_exe <= '1';
					when 37 => aluOpcode_i <= TYPE_OR; -- OR
						sel_exe <= '1';
					when 38 => aluOpcode_i <= TYPE_XOR; -- XOR
						sel_exe <= '1';
					when 40 => aluOpcode_i <= TYPE_SEQ; -- SEQ
						sel_exe <= '1';
					when 41 => aluOpcode_i <= TYPE_SNE; -- SNE
						sel_exe <= '1';
					when 42 => aluOpcode_i <= TYPE_SLT; -- SLT
						sel_exe <= '1';
					when 43 => aluOpcode_i <= TYPE_SGT; -- SGT
						sel_exe <= '1';
					when 44 => aluOpcode_i <= TYPE_SLE; -- SLE
						sel_exe <= '1';
					when 45 => aluOpcode_i <= TYPE_SGE; -- SGE
						sel_exe <= '1';
					when 46 => aluOpcode_i <= TYPE_NOP; -- MULT
						sel_exe <= '0';
					when 47 => aluOpcode_i <= TYPE_MOV; -- MOV
						sel_exe <= '1';
					when 58 => aluOpcode_i <= TYPE_SLTU; -- SLTU
						sel_exe <= '1';
					when 59 => aluOpcode_i <= TYPE_SGTU; -- SGTU
						sel_exe <= '1';
					when 60 => aluOpcode_i <= TYPE_SLEU; -- SLEU
						sel_exe <= '1';
					when 61 => aluOpcode_i <= TYPE_SGEU; -- SGEU
						sel_exe <= '1';
					when others => aluOpcode_i <= TYPE_NOP; -- NON-ASSIGNED OPERATIONS
						sel_exe <= '0';
				end case;
			when 2 => aluOpcode_i <= TYPE_ADD; -- J
				sel_exe <= '1';
			when 3 => aluOpcode_i <= TYPE_ADD; -- JAL
				sel_exe <= '1';
			when 4 => aluOpcode_i <= TYPE_ADD; -- BEQZ 
				sel_exe <= '1';
			when 5 => aluOpcode_i <= TYPE_ADD; -- BNEZ
				sel_exe <= '1';
			when 8 => aluOpcode_i <= TYPE_ADD; -- ADDI
				sel_exe <= '1';
			when 9 => aluOpcode_i <= TYPE_ADD; -- ADDUI
				sel_exe <= '1';
			when 10 => aluOpcode_i <= TYPE_SUB; -- SUBI 
				sel_exe <= '1';
			when 11 => aluOpcode_i <= TYPE_SUB; -- SUBUI 
				sel_exe <= '1';
			when 12 => aluOpcode_i <= TYPE_AND; -- ANDI
				sel_exe <= '1';
			when 13 => aluOpcode_i <= TYPE_OR; -- ORI
				sel_exe <= '1';
			when 14 => aluOpcode_i <= TYPE_XOR; -- XORI
				sel_exe <= '1';
			when 15 => aluOpcode_i <= TYPE_SLL; -- LHI
				sel_exe <= '1';
			when 18 => aluOpcode_i <= TYPE_NOP; -- JR
				sel_exe <= '1';
			when 19 => aluOpcode_i <= TYPE_NOP; -- JALR
				sel_exe <= '1';
			when 20 => aluOpcode_i <= TYPE_SLL; -- SLLI
				sel_exe <= '1';
			when 21 => aluOpcode_i <= TYPE_NOP; -- NOP
				sel_exe <= '1';
			when 22 => aluOpcode_i <= TYPE_SRL; -- SRLI
				sel_exe <= '1';
			when 23 => aluOpcode_i <= TYPE_SRA; -- SRAI
				sel_exe <= '1';
			when 24 => aluOpcode_i <= TYPE_SEQ; -- SEQI
				sel_exe <= '1';
			when 25 => aluOpcode_i <= TYPE_SNE; -- SNEI
				sel_exe <= '1';
			when 26 => aluOpcode_i <= TYPE_SLT; -- SLTI
				sel_exe <= '1';
			when 27 => aluOpcode_i <= TYPE_SGT; -- SGTI
				sel_exe <= '1';
			when 28 => aluOpcode_i <= TYPE_SLE; -- SLEI
				sel_exe <= '1';
			when 29 => aluOpcode_i <= TYPE_SGE; -- SGEI
				sel_exe <= '1';
			when 32 => aluOpcode_i <= TYPE_ADD; -- LB
				sel_exe <= '1';
			when 33 => aluOpcode_i <= TYPE_ADD; -- LH
				sel_exe <= '1';
			when 35 => aluOpcode_i <= TYPE_ADD; -- LW
				sel_exe <= '1';
			when 36 => aluOpcode_i <= TYPE_ADD; -- LBU
				sel_exe <= '1';
			when 37 => aluOpcode_i <= TYPE_ADD; -- LHU
				sel_exe <= '1';
			when 40 => aluOpcode_i <= TYPE_ADD; -- SB
				sel_exe <= '1';
			when 41 => aluOpcode_i <= TYPE_ADD; -- SH
				sel_exe <= '1';
			when 43 => aluOpcode_i <= TYPE_ADD; -- SW
				sel_exe <= '1';
			when 50 => aluOpcode_i <= TYPE_NOP; -- MULTI
				sel_exe <= '0';
			when 51 => aluOpcode_i <= TYPE_MOVI; -- MOVI
				sel_exe <= '1';
			when 58 => aluOpcode_i <= TYPE_SLTU; -- SLTUI
				sel_exe <= '1';
			when 59 => aluOpcode_i <= TYPE_SGTU; -- SGTUI
				sel_exe <= '1';
			when 60 => aluOpcode_i <= TYPE_SLEU; -- SLEUI
				sel_exe <= '1';
			when 61 => aluOpcode_i <= TYPE_SGEU; -- SGEUI
				sel_exe <= '1';
			when others => aluOpcode_i <= TYPE_NOP; -- NON-ASSIGNED OPERATIONS
				sel_exe <= '0';
		end case;
	end process ALU_OP_CODE_P;
end MIXED;

