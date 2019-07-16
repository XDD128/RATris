library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    Port ( C : in STD_LOGIC;
           Z : in STD_LOGIC;
           RESET : in STD_LOGIC;
           INT : in STD_LOGIC;
           OPCODE_HI_5 : in STD_LOGIC_VECTOR (4 downto 0);
           OPCODE_LO_2 : in STD_LOGIC_VECTOR (1 downto 0);
           CLK : in STD_LOGIC;
           ALU_SEL : out STD_LOGIC_VECTOR (3 downto 0);
           ALU_OPY_SEL : out STD_LOGIC;
           --I : out STD_LOGIC_VECTOR (1 downto 0);
           I_SET : out std_logic;
           I_CLR : out std_logic;
           PC_LD : out STD_LOGIC;
           PC_INC : out STD_LOGIC;
           PC_MUX_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           RF_WR : out STD_LOGIC;
           RF_WR_SEL : out STD_LOGIC_VECTOR (1 downto 0);
           --SP : out STD_LOGIC_VECTOR (2 downto 0);
           SP_LD : out STD_LOGIC;
           SP_INCR : out STD_LOGIC;
           SP_DECR : out STD_LOGIC;
           --SCR : out STD_LOGIC_VECTOR (3 downto 0);
           SCR_WE : out STD_LOGIC;
           SCR_ADDR_SEL : out STD_LOGIC_VECTOR(1 downto 0);
           SCR_DATA_SEL : out STD_LOGIC;
           RST : out STD_LOGIC;
           IO_STRB : out std_logic;
           --FLG : out STD_LOGIC_VECTOR (5 downto 0));
           FLG_C_SET : out STD_LOGIC;
           FLG_C_CLR : out STD_LOGIC;
           FLG_C_LD : out STD_LOGIC;
           FLG_Z_LD : out STD_LOGIC;
           FLG_LD_SEL : out std_logic;
           FLG_SHAD_LD : out std_logic);      
end ControlUnit;

architecture Behavioral of ControlUnit is
TYPE State_type is (ST_init, ST_fetch, ST_exec, INTRPT);
signal PS, NS: State_type;
signal s_op : std_logic_vector(6 downto 0);
--signal s_int : std_logic; --intermediate signal for interrupt

begin

s_op <= OPCODE_HI_5 & OPCODE_LO_2;
--RST <= '0';
--s_int <= INT;

process(CLK, RESET) begin --sync process
    if RESET = '1' then
        PS <= ST_init;
    elsif rising_edge(CLK) then
        PS <= NS;
        end if;
end process;

process(PS, s_op, clk, C, Z, INT) begin
    
        ALU_SEL <= "0000";
        ALU_OPY_SEL <= '0';
        
        PC_LD <= '0';
        PC_INC <= '0';
        PC_MUX_SEL <= "00";
        
        RF_WR <= '0';
        RF_WR_SEL <= "00";
        
        FLG_C_SET <= '0';
        FLG_C_CLR <= '0';
        FLG_C_LD <= '0';
        FLG_Z_LD <= '0';
        FLG_LD_SEL <= '0';
        FLG_SHAD_LD <= '0';
        
        I_SET <= '0';
        I_CLR <= '0';
        
        IO_STRB <= '0';
        RST <= '0';
        
        SP_LD <= '0';
        SP_INCR <= '0';
        SP_DECR <= '0';
        
        SCR_WE <= '0';
        SCR_ADDR_SEL <= "00";
        SCR_DATA_SEL <= '0';
    
    case (PS) is
        when ST_init =>
            RST <= '1';
            FLG_C_CLR <= '1';
            NS <= ST_fetch;
            --IO_STRB <= '0';
        when ST_fetch =>
            RST <= '0';
            PC_INC <= '1';
            NS <= ST_exec;
            --IO_STRB <= '0';
        when INTRPT =>
            NS <= ST_fetch;
            I_CLR <= '1';  
            SP_DECR <= '1';
            SCR_ADDR_SEL <= "11";
            SCR_DATA_SEL <= '1';
            SCR_WE <= '1';     
            FLG_SHAD_LD <= '1';
            PC_LD <= '1';
            PC_MUX_SEL <= "10"; 
        when ST_exec =>
            RST <= '0';
            PC_INC <= '0';
            if(INT = '1') then
                NS <= INTRPT;
            else
                NS <= ST_fetch;
            end if;
            
         
        
        case (s_op) is
            when "1100100" | "1100101" | "1100110" | "1100111" => --IN
                ALU_SEL <= "1111";
                RF_WR <= '1';
                RF_WR_SEL <= "11";
            when "0001001" => --MOV reg-reg
                ALU_SEL <= "1110";
                RF_WR <= '1';
            when "1101100" | "1101101" | "1101110" | "1101111" => --MOV reg-imm
                ALU_SEL <= "1110";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
            when "0000010" => --EXOR reg-reg
                ALU_SEL <= "0111";
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
            when "1001000" => --EXOR reg-imm
                ALU_SEL <= "0111";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
            when "1101000" | "1101001" | "1101010" | "1101011" => --OUT
                IO_STRB <= '1';
            when "0010000" => --BRN
                ALU_SEL <= "1111";
                PC_LD <= '1';
            when "0000100" => --ADD reg-reg
                ALU_SEL <= "0000";
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "1010000" | "1010001" | "1010010" | "1010011"=> --ADD reg-imm
                ALU_SEL <= "0000";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "0000101" => --ADDC reg-reg
                ALU_SEL <= "0001";
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "1010100" | "1010101" | "1010110" | "1010111"=> --ADDC reg-imm
                ALU_SEL <= "0001";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "0000000" => --AND reg-reg
                ALU_SEL <= "0101";
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
            when "1000000" | "1000001" | "1000010" | "1000011" => --AND reg-imm
                ALU_SEL <= "0101";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
               -- IO_STRB <= '1';
            when "0100100" => --ASR
                ALU_SEL <= "1101";

                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
--            when "0010101" => --BRCC
--                    ALU_SEL <= "1111";
--                    ALU_OPY_SEL <= '0';
--                    PC_LD <= '1';
--                    --PC_INC <= '0';
--                    PC_MUX_SEL <= "11";
--                    RF_WR <= '0';
--                    RF_WR_SEL <= "00";
--                    FLG_C_SET <= '0';
--                    FLG_C_CLR <= '0';
--                    FLG_C_LD <= '0';
--                    FLG_Z_LD <= '0';
                    
            when "0010101" => --BRCC
                if (C = '0') then
                    ALU_SEL <= "1111";
                    PC_LD <= '1';
                    --PC_INC <= '0';
                 else
                    ALU_SEL <= "1111";
                    end if;
            when "0010100" => --BRCS
                if (C = '1') then
                    ALU_SEL <= "1111";
                    PC_LD <= '1';
                else
                    ALU_SEL <= "1111";
                 end if;
            when "0010010" => --BREQ
                if (Z = '1') then
                    ALU_SEL <= "1111";
                    PC_LD <= '1';
                else
                    ALU_SEL <= "1111";
                 end if;
            when "0010011" => --BRNE
                if (Z = '0') then
                    ALU_SEL <= "1111";
                    PC_LD <= '1';
                  end if;
            when "0110000" => --CLC
                ALU_SEL <= "1111";
                FLG_C_CLR <= '1';
               -- IO_STRB <= '1';
            when "0001000" => --CMP reg-reg
                ALU_SEL <= "0100";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "1100000" | "1100001" | "1100010" | "1100011"=> --CMP reg-imm
                ALU_SEL <= "0100";
                ALU_OPY_SEL <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "0001010" => --LD reg-reg
                RF_WR <= '1';
                RF_WR_SEL <= "01";
                SCR_ADDR_SEL <= "00";
            when "1110000" | "1110001" | "1110010" | "1110011"=> --LD reg-imm
                RF_WR <= '1';
                RF_WR_SEL <= "01";
                SCR_ADDR_SEL <= "01";
            when "0100000" => --LSL 
                ALU_SEL <= "1001";
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "0100001" => --LSR
                ALU_SEL <= "1010";
                RF_WR <= '1';
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
            when "0000001" => --OR reg-reg
                ALU_SEL <= "0110";
                ALU_OPY_SEL <= '0';
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
            when "1000100" | "1000101" | "1000110" | "1000111"=> --OR reg-imm
                ALU_SEL <= "0110";
                ALU_OPY_SEL <= '1';
                RF_WR <= '1';
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
            when "0100010" => --ROL
                    ALU_SEL <= "1011";
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                   -- IO_STRB <= '1';
                when "0100011" => --ROR
                    ALU_SEL <= "1100";
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "0110001" => --SEC
                    ALU_SEL <= "1111";
                    FLG_C_SET <= '1';
                when "0001011" => --ST reg-reg
                    SCR_WE <= '1';
                    SCR_DATA_SEL <= '0';
                    SCR_ADDR_SEL <= "00";
                when "1110100" | "1110101" | "1110111" | "1110110" => --ST reg-imm
                    SCR_WE <= '1';
                    SCR_DATA_SEL <= '0';
                    SCR_ADDR_SEL <= "01";
                when "0000110" => --SUB reg-reg 
                    ALU_SEL <= "0010";
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "1011000" | "1011001" | "1011010" | "1011011"=> --SUB reg-immed
                    ALU_SEL <= "0010";
                    ALU_OPY_SEL <= '1';
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "0000111" => --SUBC reg-reg
                    ALU_SEL <= "0011";
                    ALU_OPY_SEL <= '0';
                    PC_LD <= '0';
                  --  PC_INC <= '0';
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                   -- IO_STRB <= '1';
                when "1011100" | "1011101" | "1011110" | "1011111"=> --SUBC reg-imm
                    ALU_SEL <= "0011";
                    ALU_OPY_SEL <= '1';
                    RF_WR <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "0000011" => --TEST reg-reg
                    ALU_SEL <= "1000";
                   -- IO_STRB <= '1';
                when "1001100" | "1001101" | "1001110" | "1001111" => --TEST reg-imm
                    ALU_SEL <= "1000";
                    ALU_OPY_SEL <= '1';
                when "0010001" => --CALL
                    SCR_DATA_SEL <= '1';
                    SCR_WE <= '1';
                    SCR_ADDR_SEL <= "11";
                    PC_MUX_SEL <= "00";
                    SP_DECR <= '1';
                    PC_LD <= '1';
                when "0110010" => --RET
                    SP_INCR <= '1';
                    PC_MUX_SEL <= "01";
                    SCR_ADDR_SEL <= "10";
                    PC_LD <= '1';
                when "0100101" => --PUSH
                    SP_DECR <= '1';
                    SCR_ADDR_SEL <= "11";
                    SCR_DATA_SEL <= '0';
                    SCR_WE <= '1';
                when "0100110" => --POP
                    SP_INCR <= '1';
                    RF_WR <= '1';
                    RF_WR_SEL <= "01";
                    SCR_ADDR_SEL <= "10";
                when "0101000" => --WSP
                    SP_LD <= '1';
                when "0110110" => --RETID
                    I_CLR <= '1';
                    PC_LD <= '1';
                    PC_MUX_SEL <= "01";
                    SP_INCR <= '1';
                    SCR_ADDR_SEL <= "10";
                    FLG_LD_SEL <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "0110111" => --RETIE
                    --s_int <= INT;
                    I_SET <= '1';
                    PC_LD <= '1';
                    PC_MUX_SEL <= "01";
                    SP_INCR <= '1';
                    SCR_ADDR_SEL <= "10";
                    FLG_LD_SEL <= '1';
                    FLG_C_LD <= '1';
                    FLG_Z_LD <= '1';
                when "0110100" => --SEI
                    --s_int <= INT;
                    I_SET <= '1';
                when "0110101" => --CLI
                    --s_int <= '0';
                    I_CLR <= '1';
                                                                             
            when others => --others
                ALU_SEL <= "1111";
                ALU_OPY_SEL <= '0';
                PC_LD <= '0';
              --  PC_INC <= '0';
                PC_MUX_SEL <= "00";
                RF_WR <= '0';
                RF_WR_SEL <= "00";
                FLG_C_SET <= '0';
                FLG_C_CLR <= '0';
                FLG_C_LD <= '0';
                FLG_Z_LD <= '0';

        end case;
        
        when others =>
                    NS <= ST_init;
                    --IO_STRB <= '0';
                end case;
  end process;
  
end Behavioral;