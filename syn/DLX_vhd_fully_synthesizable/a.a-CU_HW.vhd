library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

ENTITY CU_HW is
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
    OP_TYPE_FORWARD : out std_logic_vector(1 downto 0) -- in decode
	);
 end CU_HW;

architecture MIXED of CU_HW is
	
	signal opcode : std_logic_vector(OP_CODE_SIZE - 1 downto 0);
	signal func   : std_logic_vector(5 downto 0);    
	signal en_rf_decode, en_rf_wb : std_logic;

  	signal cw_fet : std_logic_vector(CW_SIZE -1 downto 0); -- fetch stage and following
  	signal cw_dec : std_logic_vector(CW_SIZE - 1 - 2 downto 0); -- decode stage and following
  	signal cw_exe : std_logic_vector(CW_SIZE - 1 - 2 - 9 downto 0); -- execution and following
  	signal cw_mem : std_logic_vector(CW_SIZE - 1 - 2 - 9 - 5 downto 0); -- memory and following
  	signal cw_wb : std_logic_vector(CW_SIZE  - 1 - 2 - 9 - 5 - 7 downto 0); -- write back and following

  	signal aluOpcode_i: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP; 
  	signal aluOpcode1: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP;
	signal aluopcode2: std_logic_vector(FUNC_SIZE-1 downto 0) := TYPE_NOP;
	signal sel_exe, sel_exe1, sel_exe2: std_logic;

	constant zero_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0) := (others => '0');

	type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  	signal cw : mem_array;
begin

cw <= ("100111111010000000101001110", -- R-TYPE
"000000000000000000000000000", -- 
"111100001100000000001000000", -- J
"111100001110000000111000010", -- JAL
"101110001100000000001101010", -- BEQZ
"101110001100000000001101010", -- BNEZ     
"000000000000000000000000000", --
"000000000000000000000000000", --
"101110101010000000101000110", -- ADDI
"100110101010000000101000110", -- ADDUI - FARE
"101110101010000000101000110", -- SUBI			10
"100110101010000000101000110", -- SUBUI - FARE
"100110101010000000101000110", -- ANDI
"100110101010000000101000110", -- ORI
"100110101010000000101000110", -- XORI
"101100001010000000101000011", -- LHI  
"000000000000000000000000000", --
"000000000000000000000000000", --
"100110101000000000001000110", -- JR - FARE
"100110101010000000111000110", -- JALR - FARE
"100110101010000000101000110", -- SLLI			20
"100100001010000000001000000", -- NOP
"100110101010000000101000110", -- SRLI
"100110101010000000101000110", -- SRAI - FARE 
"101110101010000000101000110", -- SEQI - FARE
"101110101010000000101000110", -- SNEI
"101110101010000000101000110", -- SLTI - FARE
"101110101010000000101000110", -- SGTI - FARE
"101110101010000000101000110", -- SLEI
"101110101010000000101000110", -- SGEI
"000000000000000000000000000", --			30
"000000000000000000000000000", --
"101111101010011011101010110", -- LB - FARE		
"101111101010101011101010110", -- LH - FARE
"000000000000000000000000000", --
"101111101010001011101010110", -- LW
"101111101010111011101010110", -- LBU - FARE
"101111101011001011101010110", -- LHU - FARE
"000000000000000000000000000", --
"000000000000000000000000000", --
"101111101010010110001001110", -- SB - FARE		40
"101111101010100110001001110", -- SH - FARE	
"000000000000000000000000000", --	
"101111101010000110001001110", -- SW
"000000000000000000000000000", --				
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"101110101010000000101000110", -- MULTI			50 
"100110101010000000101000110", -- MOVI			
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"000000000000000000000000000", --
"100110101010000000101000110", -- SLTUI - FARE
"100110101010000000101000110", -- SGTUI - FARE
"100110101010000000101000110", -- SLEUI - FARE		60
"100110101010000000101000110"  -- SGEUI - FARE
					);

	func <= IR_IN(5 downto 0);
	opcode <= IR_IN(I_SIZE-1 downto I_SIZE-OP_CODE_SIZE);

	cw_assegnation: process(OPCODE, FLUSH, STALL)
	begin
		if (STALL = '1') then 
			cw_fet <= cw_fet and "011111111111111111110111111";
		elsif (FLUSH = '1' ) then --AND ((conv_integer(unsigned(OPCODE)) = 4) OR (conv_integer(unsigned(OPCODE)) = 5))) then 
 			cw_fet <= cw(21); -- NOP -- PER FAR COMUNQUE ANDARE AVANTI il PC
		else
			cw_fet <= cw(conv_integer(OPCODE));
		end if;
	end process cw_assegnation;

	EN_FETCH <= cw_fet(CW_SIZE - 1);
	EN_PC <= cw_fet(CW_SIZE-21);
 
	SEL_SIGN_DECODE <= cw_dec(CW_SIZE-3 downto CW_SIZE-4);
    	EN_DECODE <= cw_dec(CW_SIZE-5) when STALL = '0' else '0';
	en_rf_decode <= cw_dec(CW_SIZE-26);
	EN_RF <= en_rf_decode or en_rf_wb; 
    	RD1_EN_RF <= cw_dec(CW_SIZE-6);
    	RD2_EN_RF <= cw_dec(CW_SIZE-7);
    	OP_TYPE_HAZARD <= cw_dec(CW_SIZE-22 downto CW_SIZE-23);
    	OP_TYPE_FORWARD <= cw_dec(CW_SIZE-24 downto CW_SIZE-25);

    	SEL_A_EXE <= cw_exe(CW_SIZE-12);
    	SEL_B_EXE <= cw_exe(CW_SIZE-13);
    	EN_ALU_EXE <= cw_exe(CW_SIZE-14);
    	SEL_MUX_JUMP_ALU_REGA <= cw_exe(CW_SIZE-15);
    	SEL_LHI <= cw_exe(CW_SIZE-27);

    	EN_LMD_MEM <= cw_mem(CW_SIZE-17);
    	SEL <= cw_mem(CW_SIZE-18 downto CW_SIZE-20);
    	RM <= cw_mem(CW_SIZE-21);
    	WM <= cw_mem(CW_SIZE-22);
    	EN <= cw_mem(CW_SIZE-23);

	SEL_WB <= cw_wb(CW_SIZE-24);
	en_rf_wb <= cw_wb(CW_SIZE-27);
	WR_EN_RF <= cw_wb(CW_SIZE-25);
	SEL_ADD_WR <= cw_wb(CW_SIZE-26);


 -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  
    if Rst = '1' then                   -- asynchronous reset --
      	cw_dec <= (others => '0');
      	cw_exe <= (others => '0');
      	cw_mem <= (others => '0');
      	cw_wb <= (others => '0');
      	aluOpcode2 <= TYPE_NOP;
      	aluOpcode1 <= TYPE_NOP;
	sel_exe2 <= '1';
	sel_exe1 <= '1';

    elsif Clk'event and Clk = '1' then  -- synchronous normal behavior (without reset) --
	if (FLUSH = '1') then -- AND ((conv_integer(unsigned(OPCODE)) = 4) OR (conv_integer(unsigned(OPCODE)) = 5))) then 
		cw_dec <= ("0010000000000000000000000"); -- EN DECODE A 1 ALTRIMENTI LA FLUSH NON SI AZZERA MAI
		cw_exe <= (others => '0');
      	aluOpcode2 <= aluOpcode1;
      	aluOpcode1 <= aluOpcode_i;
	sel_exe2 <= sel_exe1;
	sel_exe1 <= sel_exe;
    	elsif (STALL = '1') then
		--cw_dec <= cw_dec and "1111111010111110101111101";
		cw_exe <= "0010100000000000";
      	aluOpcode2 <= aluOpcode2;
      	aluOpcode1 <= aluOpcode1;
	sel_exe2 <= sel_exe2;
	sel_exe1 <= sel_exe1;
	else 
		cw_dec <= cw_fet(CW_SIZE-2 downto CW_SIZE-20)&cw_fet(CW_SIZE-22 downto 0);
		cw_exe <= cw_dec(CW_SIZE-8 downto CW_SIZE-21) & cw_dec(CW_SIZE-26 downto CW_SIZE-27);
      	aluOpcode2 <= aluOpcode1;
      	aluOpcode1 <= aluOpcode_i;
	sel_exe2 <= sel_exe1;
	sel_exe1 <= sel_exe;
	end if;
	cw_mem <= cw_exe(CW_SIZE-16 downto 1);
	cw_wb <= cw_mem(CW_SIZE-24 downto 0);

    end if;
  end process CW_PIPE;

SEL_EXE_UNIT_TYPE <= sel_exe2;
ALU_MODE <= aluOpcode2;
-- combinational generation of control alu signals --
   ALU_OP_CODE_P : process (OPCODE, FUNC)
   begin  -- process ALU_OP_CODE_P
	case conv_integer(unsigned(OPCODE)) is
	        -- case of R type requires analysis of FUNC --
		when 0 =>
			case conv_integer(unsigned(FUNC)) is
				when 4 => aluOpcode_i <= TYPE_SLL;
					sel_exe <= '1';
				when 6 => aluOpcode_i <= TYPE_SRL;
					sel_exe <= '1';
				when 7 => aluOpcode_i <= TYPE_SRA;
					sel_exe <= '1';
				when 32 => aluOpcode_i <= TYPE_ADD; 
					sel_exe <= '1';
				when 33 => aluOpcode_i <= TYPE_ADD; -- ADDU
					sel_exe <= '1';
				when 34 => aluOpcode_i <= TYPE_SUB; 
					sel_exe <= '1';
				when 35 => aluOpcode_i <= TYPE_SUB; -- SUBU
					sel_exe <= '1';
				when 36 => aluOpcode_i <= TYPE_AND; 
					sel_exe <= '1';
				when 37 => aluOpcode_i <= TYPE_OR; 
					sel_exe <= '1';
				when 38 => aluOpcode_i <= TYPE_XOR; 
					sel_exe <= '1';
				when 40 => aluOpcode_i <= TYPE_SEQ; 
					sel_exe <= '1';
				when 41 => aluOpcode_i <= TYPE_SNE; 
					sel_exe <= '1';
				when 42 => aluOpcode_i <= TYPE_SLT; 
					sel_exe <= '1';
				when 43 => aluOpcode_i <= TYPE_SGT; 
					sel_exe <= '1';
				when 44 => aluOpcode_i <= TYPE_SLE; 
					sel_exe <= '1';
				when 45 => aluOpcode_i <= TYPE_SGE; 
					sel_exe <= '1';
				when 46 => aluOpcode_i <= TYPE_NOP; -- MULT
					sel_exe <= '0';
				when 47 => aluOpcode_i <= TYPE_MOV; -- MOV
					sel_exe <= '1';
				when 58 => aluOpcode_i <= TYPE_SLTU; 
					sel_exe <= '1';
				when 59 => aluOpcode_i <= TYPE_SGTU; 
					sel_exe <= '1';
				when 60 => aluOpcode_i <= TYPE_SLEU; 
					sel_exe <= '1';
				when 61 => aluOpcode_i <= TYPE_SGEU; 
					sel_exe <= '1';
				when others => aluOpcode_i <= TYPE_NOP;
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

