
library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity FORWARDING_UNIT is
    GENERIC (NBIT: integer := ADD_RF_LENGTH);
    PORT(CLK : IN std_logic;
         RST : IN std_logic;
         FLUSH : IN std_logic;
         STALL : IN std_logic;
         OP_TYPE: IN std_logic_vector(1 downto 0); -- 11 R-TYPE, 01 IMMEDIATE, 10 BRANCH OR JUMP
         RS1: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RS2: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RD1: IN std_logic_vector(NBIT-1 DOWNTO 0);
         RD2: IN std_logic_vector(NBIT-1 DOWNTO 0);
         SEL_FW_A: OUT std_logic_vector(1 DOWNTO 0);
         SEL_FW_B: OUT std_logic_vector(1 DOWNTO 0);
         SEL_FW_BRANCH : OUT std_logic_vector(1 DOWNTO 0)
    );
end FORWARDING_UNIT;

architecture behavioral of FORWARDING_UNIT is
    signal SEL_FW_A_next, SEL_FW_B_next : std_logic_vector (1 downto 0);
    constant zero_vector : std_logic_vector(NBIT-1 downto 0) := (others => '0');
    signal flush1, flush2 : std_logic;

begin
    -- Process to handle source address register updates
    SOURCE_ADDR_REG: PROCESS (CLK)
    begin
        if (clk'event and clk='1') then
            if (rst = '1') then
                -- Reset the forwarding signals and flush control signals
                SEL_FW_A <= (others => '0');
                SEL_FW_B <= (others => '0');
                flush1 <= '0';
                flush2 <= '0';
            else
                -- Update the forwarding signals and flush control signals
                SEL_FW_A <= SEL_FW_A_next;
                SEL_FW_B <= SEL_FW_B_next;
                flush1 <= FLUSH;
                flush2 <= flush1;
            end if;
        end if;
    end process;

    -- Process to generate forwarding signals for operand A of ALU
    SEL_FW_A_GEN: PROCESS (RS1, RD1, RD2, OP_TYPE, flush2)
    begin
        SEL_FW_A_next <= "00"; -- Initialize forwarding signal to "00"
        if (flush2 = '0') then -- Check if flush is not active
            if OP_TYPE = "11" or OP_TYPE = "01" then -- R-TYPE or IMMEDIATE
                if (RS1 = RD1) and (RS1 /= zero_vector) then 
                    SEL_FW_A_next <= "10"; -- Forward from RD1
                elsif (RS1 = RD2) and (RS1 /= zero_vector) then 
                    SEL_FW_A_next <= "11"; -- Forward from RD2
                end if;
            end if;
        end if;
    end process SEL_FW_A_GEN;

    -- Process to generate forwarding signals for operand B of ALU
    SEL_FW_B_GEN: PROCESS (RS2, RD1, RD2, OP_TYPE, flush2)
    begin
        SEL_FW_B_next <= "00"; -- Initialize forwarding signal to "00"
        if (flush2 = '0') then -- Check if flush is not active
            if OP_TYPE = "11" then -- R-TYPE
                if (RS2 = RD1) and (RS2 /= zero_vector) then 
                    SEL_FW_B_next <= "10"; -- Forward from RD1
                elsif (RS2 = RD2) and (RS2 /= zero_vector) then 
                    SEL_FW_B_next <= "11"; -- Forward from RD2
                end if;
            end if;
        end if;
    end process SEL_FW_B_GEN;

    -- Process to generate forwarding signals for branch operations
    SEL_FW_BRANCH_GEN: PROCESS (RS1, RD2, OP_TYPE, flush2)
    begin
        SEL_FW_BRANCH <= "00"; -- Initialize forwarding signal to "00"
        if (flush2 = '0') then -- Check if flush is not active
            if OP_TYPE = "10" then -- BRANCH-TYPE
                if (RS1 = RD2) and (RS1 /= zero_vector) then 
                    SEL_FW_BRANCH <= "10"; -- Forward from RD2
                end if;
            end if;
        end if;
    end process SEL_FW_BRANCH_GEN;

end behavioral;