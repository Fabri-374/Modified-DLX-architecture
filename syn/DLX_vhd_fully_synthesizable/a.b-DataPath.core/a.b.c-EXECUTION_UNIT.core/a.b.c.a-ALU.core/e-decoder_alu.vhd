-- decoder that receives in input the MODE signal and based on this generate the control signals for all the other ALU components -- 
-- the mode signal can be the FUNCTION of our DLX, and the value are based on the standard DLX instruction set -- 
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.myTypes.all;

entity DECODER_ALU is
    port (
        MODE:   in std_logic_vector(5 downto 0);
        SEL_LOGIC : out std_logic_vector(2 downto 0);
        SEL_COMP : out std_logic_vector(3 downto 0);
        SEL_OUT : out std_logic_vector(1 downto 0);
 	SEL_SHIFT : out std_logic_vector(1 downto 0); 
        CIN : out std_logic;
	SEL_MOV: out std_logic;
	SEL_MOVI: out std_logic);
end entity;

architecture behavioral of DECODER_ALU is
begin
    -- behavioral description of the decoder unit for the control signals-- 
    process(MODE)
        -- variables used to assign values to the corresponding signals (represented by "name"_t) -- 
        variable sel_logic_t : std_logic_vector(2 downto 0); 
	variable sel_comp_t : std_logic_vector(3 downto 0);
        variable sel_out_t, sel_shift_t : std_logic_vector(1 downto 0);
        variable cin_t, sel_mov_t, sel_movi_t: std_logic;
    
    begin
        -- default assignment at each iteration--
        sel_logic_t := "000";
        sel_comp_t := "0000";
        sel_out_t := "00";
  	sel_shift_t := "11";
        cin_t :='0';
        sel_mov_t :='0';
        sel_movi_t :='0';

        -- effective decoder implementation for each ALU executable instruction based on the standard DLX instruction set mapping --
        case MODE is
            -- basic instruction --
            when TYPE_ADD => -- add --
                sel_out_t := "00";
                cin_t := '0';
            when TYPE_AND => -- and --
                sel_logic_t := "100";
                sel_out_t := "10";
            when TYPE_OR => -- or -- 
                sel_logic_t := "110";
                sel_out_t := "10";
            when TYPE_SGE => -- sge -- 
                sel_out_t := "11";
                sel_comp_t := "1011";
		cin_t := '1';
            when TYPE_SLE => -- sle -- 
                sel_out_t := "11";
                sel_comp_t := "1000";
		cin_t := '1';
            when TYPE_SLL => -- sll -- 
                sel_out_t := "01";
  		sel_shift_t := "00";
            when TYPE_SNE => -- sne -- 
                sel_out_t := "11";
                sel_comp_t := "0101";
		cin_t := '1';
            when TYPE_SRL => -- srl -- 
                sel_out_t := "01";
 		sel_shift_t := "01";
            when TYPE_SRA => -- sra -- 
                sel_out_t := "01";
 		sel_shift_t := "11";
            when TYPE_SUB => -- sub -- 
                sel_out_t := "00";
                cin_t := '1';
            when TYPE_XOR => -- xor -- 
                sel_logic_t := "010";
                sel_out_t := "10";

            -- added instructions -- 
            when TYPE_SEQ => -- seq -- 
                sel_comp_t := "1100";
                sel_out_t := "11";
		cin_t := '1';
            when TYPE_SGT => -- sgt -- 
                sel_comp_t := "1010";
                sel_out_t := "11";
		cin_t := '1';
            when TYPE_SLT => -- slt -- 
                sel_comp_t := "1001";
                sel_out_t := "11";
		cin_t := '1';
            when TYPE_SLTU => -- sltu -- 
                sel_comp_t := "0001";
                sel_out_t := "11";
		cin_t := '1';
            when TYPE_SGTU => -- sgtu -- 
                sel_comp_t := "0010";
                sel_out_t := "11";
		cin_t := '1';
            when TYPE_SLEU => -- sleu -- 
                sel_out_t := "11";
                sel_comp_t := "0000";
		cin_t := '1';
            when TYPE_SGEU => -- sgeu -- 
                sel_out_t := "11";
                sel_comp_t := "0011";
		cin_t := '1';
            when TYPE_MOV => -- mov--
                sel_out_t := "00";
                cin_t := '0';
		sel_mov_t := '1';
            when TYPE_MOVI => -- mov--
                sel_out_t := "00";
                cin_t := '0';
		sel_movi_t := '1';
            when others => -- nop --
                sel_logic_t := "000";
                sel_out_t := "00";
		sel_shift_t := "11";
                cin_t :='0';
                sel_comp_t := "0000";
        end case;
        
        -- signals update --
        sel_logic <= sel_logic_t;
        sel_comp <= sel_comp_t;
        sel_out <= sel_out_t;
	sel_shift <= sel_shift_t;
        cin <= cin_t;
	sel_mov <= sel_mov_t;
	sel_movi <= sel_movi_t;

    end process;
 end behavioral;
