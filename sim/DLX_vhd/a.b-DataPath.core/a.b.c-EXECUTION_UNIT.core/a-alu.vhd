-- DLX parametric ALU that is able to perform all the designed instruction results --
-- It is composed by structural architecture and a behavioral decoder to assign the correct control values starting from the MODE bits -- 
-- The structural part contains the adder made the P4-adder, the logic unit, the shift unit and the comparator unit -- 

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity ALU is
    generic (
        NBIT :		integer := 32;
        NBIT_PER_BLOCK : integer := 4);
    port (
        A :		in	std_logic_vector(NBIT-1 downto 0);
        B :		in	std_logic_vector(NBIT-1 downto 0);
	    SEL_LHI : in std_logic;
        MODE:   in std_logic_vector(5 downto 0);
        S :		out	std_logic_vector(NBIT-1 downto 0));
end entity;

architecture structural of ALU is

-- components declaration area -- 

-- Pentium4 adder component declaration --
component P4_ADDER is
    generic (
        NBIT :		integer := 32;
        NBIT_PER_BLOCK : integer := 4);
    port (
        A :		in	std_logic_vector(NBIT-1 downto 0);
        B :		in	std_logic_vector(NBIT-1 downto 0);
        Cin :	in	std_logic;
        S :		out	std_logic_vector(NBIT-1 downto 0);
        Cout :	out	std_logic);
end component P4_ADDER;

-- shift unit component declaration -- 
component T2_shifter is
	generic(
		N: integer:= NumBit);
	port(	
		A: in std_logic_vector(N-1 downto 0);		
		B: in std_logic_vector(4 downto 0);							
		sel: in std_logic_vector(1 downto 0);
		Y: out std_logic_vector(N-1 downto 0));
end component T2_shifter;

-- logic unit component declaration -- 
component LOGICALS is 
    generic(NBIT: integer);
	port(	
        A: in std_logic_vector(NBIT-1 downto 0);
		B: in std_logic_vector(NBIT-1 downto 0);
        SEL: in std_logic_vector(2 downto 0);
		L: out std_logic_vector(NBIT-1 downto 0));
end component LOGICALS;

-- general 4-to-1 mux component declaration --
component MUX41_GEN is
    Generic (NBIT: integer:= 16);
    Port (	
        A:	In	std_logic_vector(NBIT-1 downto 0);
        B:	In	std_logic_vector(NBIT-1 downto 0);
        C:	In	std_logic_vector(NBIT-1 downto 0);
        D:	In	std_logic_vector(NBIT-1 downto 0);
        SEL:	In	std_logic_vector(1 downto 0);
        Y:	Out	std_logic_vector(NBIT-1 downto 0));
end component MUX41_GEN;

-- mux 2-to-1 component declaration --
component MUX21_GEN is
    Generic (NBIT: integer:= 16);
    Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
            B:	In	std_logic_vector(NBIT-1 downto 0);
            SEL:	In	std_logic;
            Y:	Out	std_logic_vector(NBIT-1 downto 0));
end component MUX21_GEN;

-- comparation unit component declaration --
component COMPARATOR is 
    Generic (NBIT: integer:= 16);
 	Port ( 	
        A :	In	std_logic_vector(NBIT-1 downto 0);
		B :	In	std_logic_vector(NBIT-1 downto 0);
		DIFF : In	std_logic_vector(NBIT-1 downto 0);
        COUT:	In	std_logic;
        SEL: in std_logic_vector(3 downto 0);
        Y:	Out	std_logic_vector(NBIT-1 downto 0));
end component COMPARATOR;

-- inverter component declaration -- 
component IV_GEN is
    generic (
        NBIT : integer := 32);
    port (
        A    : in  std_logic_vector(NBIT-1 downto 0);
        Y    : out std_logic_vector(NBIT-1 downto 0));
end component;

-- decoder component declaration
component DECODER_ALU is
    port (
        MODE:   in std_logic_vector(5 downto 0);
        SEL_LOGIC : out std_logic_vector(2 downto 0);
        SEL_COMP : out std_logic_vector(3 downto 0);
        SEL_OUT : out std_logic_vector(1 downto 0);
 	    SEL_SHIFT : out std_logic_vector(1 downto 0); 
        CIN : out std_logic;
	    SEL_MOV: out std_logic;
	    SEL_MOVI: out std_logic);
end component;

-- signals declaration area --
signal a_mov, b_neg, b_add, b_add_mov, out_add, out_logic, out_shift, out_comp, a_shifter : std_logic_vector(NBIT-1 downto 0);
signal sel_logic : std_logic_vector(2 downto 0); -- control signals for the logic and comparator units-- 
signal b_shifter: std_logic_vector(4 downto 0);
signal sel_comp : std_logic_vector(3 downto 0);
signal sel_out : std_logic_vector(1 downto 0); -- output selector signal that determines the ALU output --
signal sel_shift: std_logic_vector(1 downto 0); -- control signals for the shifter unit -- 
signal cin, cout, sel_mov, sel_movi: std_logic; -- internal signals used to perform the addition/subtraction and the comparate operations -- 

begin
    -- structural part for all the blocks and units connection --

    -- decoder used to generate the control signals for all the other components --
    ALU_DECODER : DECODER_ALU
        port map(
            MODE => MODE,
            SEL_LOGIC => sel_logic,
            SEL_COMP => sel_comp,
            SEL_OUT => sel_out,
            SEL_SHIFT => sel_shift,
            CIN => cin,
            SEL_MOV => sel_mov,
            SEL_MOVI => sel_movi
        );

    -- negated b signal used to perform the difference between A and B --
    INVERT_B : IV_GEN generic map(NBIT) 
        port map(
            A => B,
            Y => b_neg
        );
    
    -- mux used to select B or NOT B  signals used in the P4-adder --
    B_ADDER: MUX21_GEN generic map(NBIT)
        port map(
            A => b_neg,
            B => B,
            SEL => cin,
            Y => b_add
        );

    -- P4-adder instantation -- 
    ADDER: P4_ADDER generic map(NBIT, NBIT_PER_BLOCK)
        port map(
            A => a_mov,
            B => b_add_mov,
            Cin => cin,
            S => out_add,
            Cout => cout
        );

    -- mux used to select if lhi operation is performed in the shifter --
    A_SHIFTER_MUX: MUX21_GEN generic map(NBIT)
        port map(
            A => B,
            B => A,
            SEL => SEL_LHI,
            Y => a_shifter
        );

    -- mux used to select if lhi operation is performed in the shifter --
    B_SHIFTER_MUX: MUX21_GEN generic map(5)
        port map(
            A => "10000",
            B => B(4 downto 0),
            SEL => SEL_LHI,
            Y => b_shifter
        );

    -- mux used to select if mov operation is performed --
    MOV_MUX: MUX21_GEN generic map(NBIT)
        port map(
            A => (others=>'0'),
            B => b_add,
            SEL => sel_mov,
            Y => b_add_mov
        );

    -- mux used to select if movi operation is performed --
    MOVI_MUX: MUX21_GEN generic map(NBIT)
        port map(
            A => (others=>'0'),
            B => A,
            SEL => sel_movi,
            Y => a_mov
        );

    -- shift unit instantation --
    SHIFTER: T2_shifter generic map(NBIT)
        port map(
            A => a_shifter,
            B => b_shifter,
            sel => sel_shift,
            Y => out_shift
        );

    -- logic unit instantation --
    LOGICAL: LOGICALS generic map(NBIT)
        port map(
            A => A,
            B => B,
            SEL => sel_logic,
            L => out_logic
        );

    -- comparation unit instantation --
    COMP : COMPARATOR generic map(NBIT)
        port map(
            A => A,
            B => B,
            DIFF => out_add,
            COUT => cout,
            SEL => sel_comp,
            Y => out_comp
        );

    -- output mux that selects the correct output of the ALU instructions --
    MUX_OUT_ALU : MUX41_GEN generic map(NBIT)
        port map(
            A => out_add,
            B => out_shift,
            C => out_logic,
            D => out_comp,
            SEL => sel_out,
            Y => S
        ); 

end structural;

