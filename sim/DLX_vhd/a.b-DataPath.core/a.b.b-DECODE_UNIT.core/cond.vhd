library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.constants.all;

-- Declaration of the COND entity
entity COND is
    generic (
        NBIT : integer := NumBit;
        OPCODE_SIZE : integer := OPCODE_SIZE
    );
    Port (
        Y:      In  std_logic;
        OPCODE: In  std_logic_vector(5 downto 0);
        CLK :    In  std_logic;
        RES :    In  std_logic;
        EN :     In  std_logic;
        SEL:     Out std_logic
    );
end COND;

-- Architecture definition for the COND entity
architecture behavioral of COND is

    -- Declaration of a component FD_1BIT
    component FD_1BIT is
        Port (
            D:     In  std_logic;
            CK:    In  std_logic;
            EN:    In  std_logic;
            RESET: In  std_logic;
            Q:     Out std_logic
        );
    end component;

    -- Signal declaration
    signal sel_pc : std_logic; -- SEL is 1 if the branch is taken

begin

    -- Process for branch detection
    branch_det: process (OPCODE, Y)
    variable req_tmp : std_logic;
    begin
    
        case OPCODE is
            when "000100" => -- beqz
                if(Y = '1') then 
                    req_tmp := '1';
                else 
                    req_tmp := '0';
                end if;
            when "000101" => -- bnez
                if(Y = '0') then 
                    req_tmp := '1';
                else 
                    req_tmp := '0';
                end if;
            when "000010" => -- j
                req_tmp :=  '1';
            when "000011" => -- jal
                req_tmp := '1';
            when "010011" => -- jalr
                req_tmp := '1';
            when "010010" => -- jr
                req_tmp := '1';
            when others =>
                req_tmp := '0';
        end case;
        
        sel_pc <= req_tmp;
        
    end process;

    -- Instantiating the FD_1BIT component
    reg: FD_1BIT
        port map(sel_pc, CLK, EN, RES, SEL);
    
end behavioral;
