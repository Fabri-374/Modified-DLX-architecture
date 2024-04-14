library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BOOTHMUL is
    generic (NBIT: integer := 32);
    port (
        A: in std_logic_vector(NBIT - 1 downto 0);
        B: in std_logic_vector(NBIT - 1 downto 0);
        P: out std_logic_vector(NBIT * 2 - 1 downto 0)
    );
end BOOTHMUL;

architecture MIXED_ARCH of BOOTHMUL is

    component MUX51 is
        generic (NBIT: integer := 32);
        port (
            A: in std_logic_vector(NBIT - 1 downto 0);
            A_2: in std_logic_vector(NBIT - 1 downto 0);
            ZEROS: in std_logic_vector(NBIT - 1 downto 0);
            SEL: in std_logic_vector(2 downto 0);
            Y: out std_logic_vector(NBIT - 1 downto 0)
        );
    end component;

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

    -- signal declaration space --
    signal b_enc : std_logic_vector(NBIT downto 0);
    signal zeros : std_logic_vector(NBIT * 2 - 1 downto 0);
    signal out_first_mux : std_logic_vector(NBIT * 2 - 1 downto 0);

    type arr is array (0 to NBIT / 2 - 1) of std_logic_vector(NBIT * 2 - 1 downto 0);
    signal prod_tmp, out_mux : arr;

    type arr_2 is array (0 to NBIT - 1) of std_logic_vector(NBIT * 2 - 1 downto 0); -- contains all the possible used 2*i*A
    signal a_shifted : arr_2;

begin

    b_enc <= B & '0';   -- add the -1 bit to b --
    zeros <= (others => '0');    -- create the all zero signal --
    a_shifted(0) <= zeros(NBIT - 1 downto 0) & A when A(NBIT - 1) = '0' else not(zeros(NBIT - 1 downto 0)) & A;  -- sign extension for A signal --

    GEN: for i in 0 to (NBIT / 2) - 1 generate

        a_shifted(2 * i + 1) <= a_shifted(2 * i)(NBIT * 2 - 2 downto 0) & '0';    -- generate 2*i*A --

        riga0 : if (i = 0) generate
            FIRSTMUX51: MUX51 generic map(NBIT * 2)    -- the first mux has at the output the tmp product --
                port map(
                    A => a_shifted(2 * i),
                    A_2 => a_shifted(2 * i + 1),
                    ZEROS => zeros,
                    SEL => b_enc(2 * i + 2 downto 2 * i),
                    Y => out_first_mux
                );

            -- if at the first mux the sel select a negative number, we have to add 1 to complete the A negation --
            prod_tmp(i) <= (out_first_mux + '1') when (b_enc(i + 2) = '1') else out_first_mux;
        end generate riga0;

        riga_i : if (i > 0) generate    -- the other blocks require both mux and adder --

            a_shifted(2 * i) <= a_shifted(2 * i - 1)(NBIT * 2 - 2 downto 0) & '0';   -- generate 2*i*A --

            OTH_MUX51: MUX51 generic map(NBIT * 2)
                port map(
                    A => a_shifted(2 * i),
                    A_2 => a_shifted(2 * i + 1),
                    ZEROS => zeros,
                    SEL => b_enc(2 * i + 2 downto 2 * i),
                    Y => out_mux(i)
                );

            -- for the other muxes outputs, if a negative number is requested, it is completed passing 1 in the Cin port of the RCA by using the SEL MSB --
            RCA_INST: RCA_GEN generic map(NBIT * 2)
                port map(
                    A => out_mux(i),
                    B => prod_tmp(i - 1),
                    Ci => b_enc(2 * i + 2),
                    S => prod_tmp(i),
                    Co => open
                );
        end generate riga_i;
    end generate GEN;

    P <= prod_tmp(NBIT / 2 - 1);    -- the final product in the array is the correct output of the multiplier --

end MIXED_ARCH;

