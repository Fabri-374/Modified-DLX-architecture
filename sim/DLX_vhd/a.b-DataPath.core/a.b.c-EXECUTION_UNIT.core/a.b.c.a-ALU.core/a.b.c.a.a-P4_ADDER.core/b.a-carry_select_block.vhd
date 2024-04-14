library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CARRY_SELECT is 
    generic (NBIT: integer := 16);
    port (
        A: in std_logic_vector(NBIT - 1 downto 0);
        B: in std_logic_vector(NBIT - 1 downto 0);
        Cin: in std_logic;
        S: out std_logic_vector(NBIT - 1 downto 0)
    );
end CARRY_SELECT; 

architecture STRUCTURAL of CARRY_SELECT is

    signal STMP1, STMP2, STMP: std_logic_vector(NBIT - 1 downto 0);
    signal CTMP1, CTMP2: std_logic;

    component RCA_GEN is 
        generic (NBIT: integer := 16);
        port (
            A: in std_logic_vector(NBIT - 1 downto 0);
            B: in std_logic_vector(NBIT - 1 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(NBIT - 1 downto 0);
            Co: out std_logic
        );
    end component;

    component MUX21_GEN is
        Generic (NBIT: integer := 16);
        Port (
            A: in std_logic_vector(NBIT - 1 downto 0);
            B: in std_logic_vector(NBIT - 1 downto 0);
            SEL: in std_logic;
            Y: out std_logic_vector(NBIT - 1 downto 0)
        );
    end component;

begin

    S <= STMP;

    RCA1: RCA_GEN
        generic map (NBIT) 
        port map (
            A => A,
            B => B,
            Ci => '0',
            S => STMP1,
            Co => CTMP1
        ); 

    RCA2: RCA_GEN
        generic map (NBIT) 
        port map (
            A => A,
            B => B,
            Ci => '1',
            S => STMP2,
            Co => CTMP2
        ); 

    MUX: MUX21_GEN
        generic map (NBIT) 
        port map (
            A => STMP2,
            B => STMP1,
            SEL => Cin,
            Y => STMP
        ); 

end STRUCTURAL;

configuration CFG_CARRY_STRUCTURAL of CARRY_SELECT is
    for STRUCTURAL 
        for all: RCA_GEN
            use configuration WORK.CFG_RCA_STRUCTURAL;
        end for;
    end for;
end CFG_CARRY_STRUCTURAL;

