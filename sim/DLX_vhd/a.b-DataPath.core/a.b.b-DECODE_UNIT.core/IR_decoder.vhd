library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.constants.all; 

entity IR_decoder is
	GENERIC (N: integer := NumBit);
	PORT(IR_IN: IN std_logic_vector(N -1 downto 0);
			 RS1: OUT std_logic_vector(4 DOWNTO 0);
			 RS2: OUT std_logic_vector(4 DOWNTO 0);
			 RD: OUT std_logic_vector(4 DOWNTO 0);
			 imm16: OUT std_logic_vector(15 DOWNTO 0);
			 imm26:	OUT std_logic_vector(25 DOWNTO 0));
end IR_decoder;

architecture behavioral of IR_decoder is
begin
		
	RS1 <= IR_IN(25 downto 21);  
	imm16 <= IR_IN(15 downto 0);
	imm26 <= IR_IN(25 downto 0);

	RS2_ASSIGNATION : process(IR_IN)
	begin
        	if IR_IN(N-1 downto 26) = "000000" or IR_IN(N-1 downto 26) = "101000" or IR_IN(N-1 downto 26) = "101001" or IR_IN(N-1 downto 26) = "101011"then -- R-Type or store
				RS2 <= IR_IN(20 downto 16);
        	else  -- Register-Immediate instructions
				RS2 <= "00000"; 
        	end if;
    	end process;
	RD_ASSIGNATION : process(IR_IN)
	begin
        	if IR_IN(N-1 downto 26) = "000011" or IR_IN(N-1 downto 26) = "010011" then -- JAL and JALR instructions write on R31
            	RD <= "11111"; 
        	elsif IR_IN(N-1 downto 26) = "000000" then -- Register-Register instructions
            	RD <= IR_IN(15 downto 11);
        	elsif IR_IN(N-1 downto 26) = "101000" or IR_IN(N-1 downto 26) = "101001" or IR_IN(N-1 downto 26) = "101011" or IR_IN(N-1 downto 26) = "010010" or IR_IN(N-1 downto 26) = "000100" or IR_IN(N-1 downto 26) = "0000101"then -- Store instructions or jr o branch
            	RD <= "00000"; 
        	else  -- Register-Immediate instructions
            	RD <= IR_IN(20 downto 16);
        	end if;
    	end process;

end behavioral;
