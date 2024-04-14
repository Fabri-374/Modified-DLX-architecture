library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;
use WORK.functions.all;

entity T2_shifter is
	generic(
		N: integer:= NumBit);
	port(	
		A: in std_logic_vector(N-1 downto 0);		
		B: in std_logic_vector(4 downto 0);							
		sel : in std_logic_vector(1 downto 0); -- 00 left, 01 L_right, 11 A_right --
		Y: out std_logic_vector(N-1 downto 0));
end entity T2_shifter;

architecture BEHAVIORAL of T2_shifter is

	signal mask00, mask08, mask16, mask24, correct_mask: std_logic_vector(N-1+8 downto 0);
	signal b_int : integer range 0 to 7;

begin
	
	--stage 1 masks generation --
	process(sel, A)
	begin
		case sel is
			-- LOGIC/ARITHMETIC LEFT -- 
			when "00"  => 
				mask00 <= A & x"00";
				mask08 <= A(23 downto 0) & x"0000";
				mask16 <= A(15 downto 0) &  x"000000";
				mask24 <= A(7 downto 0)  &  x"00000000";

			-- LOGIC RIGHT -- 
			when "01"  => 
				mask00 <= x"00" & A;
				mask08 <= x"0000" & A(23 downto 0);
				mask16 <= x"000000" & A(15 downto 0);
				mask24 <= x"00000000" & A(7 downto 0);

			-- ARITHMETIC RIGHT --
			when "11"  => 
				mask00 <= (39 downto 32 => A(31)) & A;
				mask08 <= (39 downto 24 => A(31)) & A(23 downto 0);
				mask16 <= (39 downto 16 => A(31)) & A(15 downto 0);
				mask24 <= (39 downto 8 => A(31)) & A(7 downto 0);

			-- INCORRECT SEL -- 
			when others => 
				mask00 <= (others => '0');
				mask08 <= (others => '0');
				mask16 <= (others => '0');
				mask24 <= (others => '0');
		end case;
	end process;

	-- stage 2 mask selection --
	process(B, mask00, mask08, mask16, mask24)
	begin
		case B(4 downto 3) is
			when "00"  => 
				correct_mask <= mask00;

			when "01"  => 
				correct_mask <= mask08;
	
			when "10"  => 
				correct_mask <= mask16;
			
			when others  => 
				correct_mask <= mask24;		
		end case;
	end process;

	-- stage 3 fine grained shift --
	b_int <= to_integer(unsigned(B(2 downto 0)));
	process(b_int, correct_mask, sel)
	begin	
			if sel(0) = '0' then
				Y <= correct_mask(N-1+8-b_int downto 8-b_int);
			else
				Y <= correct_mask(N-1+b_int downto b_int);
			end if; 
	end process;
	
end architecture BEHAVIORAL;