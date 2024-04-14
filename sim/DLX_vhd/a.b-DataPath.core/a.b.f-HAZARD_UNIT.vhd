library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity HAZARD_UNIT is
    GENERIC (NBIT: integer := ADD_RF_LENGTH);
    PORT(   CLK : IN std_logic;
             RES : IN std_logic;
             OP_TYPE: IN std_logic_vector(1 downto 0); -- MSB BRANCH, LSB LOAD
             RS1: IN std_logic_vector(NBIT-1 DOWNTO 0);
             RS2: IN std_logic_vector(NBIT-1 DOWNTO 0);
             RD: IN std_logic_vector(NBIT-1 DOWNTO 0);
             STALL : OUT std_logic
    );
end HAZARD_UNIT;

architecture behavioral of HAZARD_UNIT is
signal rd_prev : std_logic_vector(NBIT-1 DOWNTO 0);
signal zero_reg : std_logic_vector(NBIT-1 DOWNTO 0) := (others => '0');
signal op_type_load : std_logic;
begin
    -- Process to generate the next value of RD based on RES signal
    -- and generate RD's value when RES is not asserted
    NEXT_RD_GENERATION: process(CLK)
    begin
        if(CLK'event and CLK = '1') then
            if (RES= '1') then
                rd_prev <= (others => '0');
		op_type_load <= '0';
            else
                rd_prev <= RD;
		op_type_load <= OP_TYPE(0);
            end if;
        end if;
    end process NEXT_RD_GENERATION;

    -- Process to detect hazards and control the STALL signal
    HAZARD_DETECTION : process (RS1, RS2, rd_prev,  OP_TYPE)
        variable stall_tmp : std_logic;  -- Temporary variable to hold stall signal

    begin
        stall_tmp := '0';  -- Initialize stall signal to not asserted

        -- Load Hazard Detection: Check if a load instruction is dependent on RS1 or RS2
        if (op_type_load = '1') then
            if ((rd_prev = RS1) or (rd_prev = RS2))and rd_prev /= zero_reg then
                stall_tmp := '1';  -- Stall required due to load hazard
            end if;
        end if;

        -- Branch Hazard Detection: Check if a branch instruction is dependent on RS1
        if (OP_TYPE(1) = '1') then
            if (rd_prev = RS1) then
                stall_tmp := '1';  -- Stall required due to branch hazard
            end if;
        end if;

        STALL <= stall_tmp;  -- Assign the final stall signal value
    end process HAZARD_DETECTION;

end behavioral;

