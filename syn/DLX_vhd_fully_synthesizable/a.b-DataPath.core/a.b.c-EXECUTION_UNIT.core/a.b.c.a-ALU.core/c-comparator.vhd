library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity COMPARATOR is 
    Generic (NBIT: integer := 16);
    Port (
        A : in std_logic_vector(NBIT - 1 downto 0);
        B : in std_logic_vector(NBIT - 1 downto 0);
        DIFF : in std_logic_vector(NBIT - 1 downto 0);
        COUT: in std_logic; 
        SEL: in std_logic_vector(3 downto 0); -- MSB = 0 unsigned
        Y: out std_logic_vector(NBIT - 1 downto 0)
    );
end entity;

architecture mixed of COMPARATOR is 

    component MUX61_GEN is
        Generic (NBIT: integer := 16);
        Port (
            A: in std_logic_vector(NBIT - 1 downto 0);
            B: in std_logic_vector(NBIT - 1 downto 0);
            C: in std_logic_vector(NBIT - 1 downto 0);
            D: in std_logic_vector(NBIT - 1 downto 0);
            E: in std_logic_vector(NBIT - 1 downto 0);
            F: in std_logic_vector(NBIT - 1 downto 0);
            SEL: in std_logic_vector(2 downto 0);
            Y: out std_logic_vector(NBIT - 1 downto 0)
        );
    end component MUX61_GEN;

    signal out_min_eq, out_min, out_maj, out_maj_eq, out_eq, out_not_eq, nor_sum, lt, ltu, le, leu, ge, geu, gt, gtu: std_logic; -- output flags --
    signal s_out_min_eq, s_out_min, s_out_maj, s_out_maj_eq, s_out_eq, s_out_not_eq: std_logic_vector(NBIT - 1 downto 0); -- output vectors --
    signal zeros: std_logic_vector(NBIT - 2 downto 0); -- zero vector used to extend the result to the required length -- 

begin
	zeros <= (others =>'0');

    nor_sum <= '1' when DIFF = (zeros & '0') else '0';
    geu <= COUT; 
    ge  <= COUT xor (A(NBIT - 1) xor B(NBIT - 1));
    out_maj_eq <= geu when SEL(3) = '0' else ge;

    gt <= ge and out_not_eq;     
    gtu <= geu and out_not_eq;   
    out_maj <= gtu when SEL(3) = '0' else gt;

    leu <= nor_sum or (not(COUT));
    le <= (nor_sum or (not(COUT))) xor (A(NBIT - 1) xor B(NBIT - 1));
    out_min_eq <= leu when SEL(3) = '0' else le;

    lt <= le and out_not_eq;    
    ltu <= leu and out_not_eq;  
    out_min <= ltu when SEL(3) = '0' else lt;
    
    out_not_eq <= not(nor_sum);
    out_eq <= nor_sum;

    -- extension of the flags -- 
    s_out_min_eq <= zeros & out_min_eq; -- extension with the zero vector -- 
    s_out_min <= zeros & out_min; -- extension with the zero vector -- 
    s_out_maj <= zeros & out_maj; -- extension with the zero vector -- 
    s_out_maj_eq <= zeros & out_maj_eq; -- extension with the zero vector -- 
    s_out_eq <= zeros & out_eq; -- extension with the zero vector -- 
    s_out_not_eq <= zeros & out_not_eq; -- extension with the zero vector -- 

    -- the 6-to-1 mux designed to set at the output the correct flag -- 
    COMPARATOR_OUT : MUX61_GEN generic map (NBIT)
        port map(
            A => s_out_min_eq,
            B => s_out_min,
            C => s_out_maj,
            D => s_out_maj_eq,
            E => s_out_eq,
            F => s_out_not_eq,
            SEL => SEL(2 downto 0),
            Y => Y
        );
    
end architecture mixed;

