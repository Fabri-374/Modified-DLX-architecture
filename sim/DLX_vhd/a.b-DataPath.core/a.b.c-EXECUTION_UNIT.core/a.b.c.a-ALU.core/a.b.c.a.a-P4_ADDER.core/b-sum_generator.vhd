library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SUM_GENERATOR is
    generic (
        NBIT_PER_BLOCK: integer := 4;
        NBLOCKS : integer := 8
    );
    port (
        A : in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0);
        B : in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0);
        Ci : in std_logic_vector(NBLOCKS -1 downto 0);
        S : out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS -1 downto 0)
    );
end entity SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is

    component CARRY_SELECT
        generic (
            NBIT : integer := 16
        );
        port (
            A : in std_logic_vector(NBIT-1 downto 0);
            B : in std_logic_vector(NBIT-1 downto 0);
            Cin : in std_logic;
            S : out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

begin
    carry_select_gen: for i in 0 to NBLOCKS-1 generate
        -- Instantiate CARRY_SELECT for each block
        carry_sel_inst : CARRY_SELECT
            generic map (NBIT_PER_BLOCK)
            port map (
                A => A((i+1)*NBIT_PER_BLOCK-1 downto i*NBIT_PER_BLOCK),
                B => B((i+1)*NBIT_PER_BLOCK-1 downto i*NBIT_PER_BLOCK),
                Cin => Ci(i),
                S => S((i+1)*NBIT_PER_BLOCK-1 downto i*NBIT_PER_BLOCK)
            );
    end generate;

end STRUCTURAL;

configuration CFG_SUM_GENERATOR_STRUCTURAL of SUM_GENERATOR is 
    for STRUCTURAL
        for carry_select_gen
            for all: CARRY_SELECT
                use configuration WORK.CFG_CARRY_STRUCTURAL;
            end for;
        end for;
    end for;
end configuration;

