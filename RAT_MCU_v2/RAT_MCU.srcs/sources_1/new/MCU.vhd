library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MCU is
    Port ( IN_PORT : in STD_LOGIC_VECTOR (7 downto 0);
           RESET : in STD_LOGIC;
           INT : in STD_LOGIC;
           CLK : in STD_LOGIC;
           OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB : out STD_LOGIC);
end MCU;

architecture Behavioral of MCU is

component PC is Port (
           FROMIMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROMSTACK : in STD_LOGIC_VECTOR (9 downto 0);
           PCMUXSEL : in STD_LOGIC_VECTOR (1 downto 0);
           clk : in STD_LOGIC;
           pcld : in STD_LOGIC;
           pcinc : in STD_LOGIC;
           restart : in STD_LOGIC;
           pccount : out STD_LOGIC_VECTOR(9 downto 0));
end component;

component prog_rom is 
   port (     ADDRESS : in std_logic_vector(9 downto 0); 
          INSTRUCTION : out std_logic_vector(17 downto 0); 
                  CLK : in std_logic);  
end component;

component ALU is
    Port ( SEL : in STD_LOGIC_VECTOR (3 downto 0);
           A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           CIN : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0);
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end component;

component ALU_MUX is
    Port(DY_OUT : in std_logic_vector(7 downto 0);
         IR : in std_logic_vector(7 downto 0);
         ALU_OPY_SEL : in std_logic;
         dout : out std_logic_vector(7 downto 0));
end component;

component cz_flags is
  Port (clk : in std_logic;
        flg_shad_ld : in std_logic;
        flg_z_ld : in std_logic;
        Z : in std_logic;
        flg_ld_sel : in std_logic;
        flg_c_set : in std_logic;
        flg_c_ld : in std_logic;
        C : in std_logic;
        flg_c_clr : in std_logic;
        Z_FLAG : out std_logic;
        C_FLAG : out std_logic);
end component cz_flags;

--component C is
--    Port ( Cin : in STD_LOGIC;
--           LD : in STD_LOGIC;
--           SET : in STD_LOGIC;
--           CLK : in STD_LOGIC;
--           CLR : in STD_LOGIC;
--           Cout : out STD_LOGIC);
--end component;

--component Z is
--    Port ( Zin : in STD_LOGIC;
--           LD : in STD_LOGIC;
--           CLK : in STD_LOGIC;
--           Zout : out STD_LOGIC);
--end component;

--component RF is Port(
--    FROM_IN : in STD_LOGIC_VECTOR (7 downto 0);
--    FROM_SP : in STD_LOGIC_VECTOR (7 downto 0);
--    FROM_SCR : in STD_LOGIC_VECTOR (7 downto 0);
--    FROM_ALU : in STD_LOGIC_VECTOR (7 downto 0);
--    RF_WR_SEL : in STD_LOGIC_VECTOR (1 downto 0);
--    ADRX : in STD_LOGIC_VECTOR(4 downto 0);
--    ADRY : in STD_LOGIC_VECTOR(4 downto 0);
--    RF_WR : in STD_LOGIC;
--    CLK : in STD_LOGIC;
--    DX_OUT : out STD_LOGIC_VECTOR(7 downto 0);
--    DY_OUT : out STD_LOGIC_VECTOR(7 downto 0));
--end component;

component REG_FILE is
    Port ( DIN : in STD_LOGIC_VECTOR (7 downto 0);
           ADRX : in STD_LOGIC_VECTOR(4 downto 0);
           ADRY : in STD_LOGIC_VECTOR(4 downto 0);
           RF_WR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DX_OUT : out STD_LOGIC_VECTOR(7 downto 0);
           DY_OUT : out STD_LOGIC_VECTOR(7 downto 0));
end component;

component ControlUnit is
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
end component;
 


component Scratch_RAM is
    Port ( DIN : in STD_LOGIC_VECTOR(9 downto 0);
           SCR_ADDR : in STD_LOGIC_VECTOR(7 downto 0);
           SCR_WE : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR(9 downto 0));
end component;

component stack_pointer is
  Port (
    A : in std_logic_vector(7 downto 0);
    CLK : in std_logic;
    RST : in std_logic;
    SP_LD : in std_logic;
    SP_INCR : in std_logic;
    SP_DECR : in std_logic;
    DATA_OUT : out std_logic_vector(7 downto 0));
end component;

component int_f is
    Port ( clk : in STD_LOGIC;
           set : in STD_LOGIC;
           clr : in STD_LOGIC;
           dout : out STD_LOGIC);
end component int_f;

signal s_Cin : std_logic;
signal s_Zin : std_logic;
signal s_ALU_SEL : std_logic_vector(3 downto 0);
signal s_ALU_OPY_SEL : std_logic;
signal s_PC_LD : std_logic;
signal s_PC_INC : std_logic;
signal s_PC_MUX_SEL : std_logic_vector(1 downto 0);
signal s_RF_WR : std_logic;
signal s_RF_WR_SEL : std_logic_vector(1 downto 0);
signal s_RST : std_logic;
signal s_FLG_C_SET : std_logic;
signal s_FLG_C_CLR : std_logic;
signal s_FLG_C_LD : std_logic;
signal s_FLG_Z_LD : std_logic;
signal s_FLG_LD_SEL : std_logic;
signal s_FLG_SHAD_LD : std_logic;
signal s_SP_LD : std_logic;
signal s_SP_INCR : std_logic;
signal s_SP_DECR : std_logic;
signal s_SCR_WE : std_logic;
signal s_SCR_ADDR_SEL : std_logic_vector(1 downto 0);
signal s_SCR_DATA_SEL : std_logic;
signal s_DATA_OUT : std_logic_vector(7 downto 0);
signal s_DATA_OUT_SUB : std_logic_vector(7 downto 0); --DATA_OUT signal -1
signal s_SCR_ADDR : std_logic_vector(7 downto 0);
signal s_SCR_DATA : std_logic_vector(9 downto 0);

signal s_IMMED : std_logic_vector(9 downto 0);
signal s_SCR_OUT : std_logic_vector(9 downto 0);
--signal s_STACK_OUT_SHORT : std_logic_vector(7 downto 0);
signal s_PC_COUNT : std_logic_vector(9 downto 0);

signal s_IR : std_logic_vector(17 downto 0);
signal s_IR_1 : std_logic_vector(4 downto 0);
signal s_IR_2 : std_logic_vector( 4 downto 0);
signal s_IR_8 : std_logic_vector(7 downto 0);

signal s_SP_OUT : std_logic_vector(7 downto 0);
signal s_DX_OUT : std_logic_vector(7 downto 0);
signal s_DY_OUT : std_logic_vector(7 downto 0);
signal s_IR_HI : std_logic_vector(4 downto 0);
signal s_IR_LO : std_logic_vector(1 downto 0);

signal s_ALU_MUX_OUT : std_logic_vector(7 downto 0);

signal s_Cout : std_logic;
signal s_Zout : std_logic;

signal s_RESULT : std_logic_vector(7 downto 0);
signal s_IO : std_logic;
signal s_DIN : std_logic_vector(7 downto 0);

signal s_set : std_logic;
signal s_clr : std_logic;
signal s_int_f : std_logic;
signal s_int : std_logic;

begin

--s_STACK_OUT_SHORT <= s_STACK_OUT(7 downto 0);
s_DATA_OUT_SUB <= std_logic_vector(unsigned(s_DATA_OUT) - 1);

with s_RF_WR_SEL select
    s_DIN <= s_RESULT when "00",
            s_SCR_OUT(7 downto 0) when "01",
            s_DATA_OUT(7 downto 0) when "10",
            IN_PORT when others;
            
with s_SCR_ADDR_SEL select
    s_SCR_ADDR <= s_DY_OUT when "00",
                  s_IR(7 downto 0) when "01",
                  s_DATA_OUT when "10",
                  s_DATA_OUT_SUB when others;
                  
with s_SCR_DATA_SEL select
    s_SCR_DATA <= "00" & s_DX_OUT when '0',
                  s_PC_COUNT when '1',
                  "0000000000" when others;

s_IR_1 <= s_IR(12 downto 8);
s_IR_2 <= s_IR(7 downto 3);
s_IR_8 <= s_IR(7 downto 0);
s_IR_HI <= s_IR(17 downto 13);
s_IR_LO <= s_IR(1 downto 0);
s_immed <= s_IR(12 downto 3);

s_int <= INT AND s_int_f;

cu : ControlUnit port map (C => s_Cin,
                           Z => s_Zin,
                           RESET => RESET,
                           INT => s_int,
                           OPCODE_HI_5 => s_IR_HI,
                           OPCODE_LO_2 => s_IR_LO,
                           CLK => CLK,
                           ALU_SEL => s_ALU_SEL,
                           ALU_OPY_SEL => s_ALU_OPY_SEL,
                           I_SET => s_set,
                           I_CLR => s_clr,
                           PC_LD => s_PC_LD,
                           PC_INC => s_PC_INC,
                           PC_MUX_SEL => s_PC_MUX_SEL,
                           RF_WR => s_RF_WR,
                           RF_WR_SEL => s_RF_WR_SEL,
                           RST => s_RST,
                           IO_STRB => IO_STRB,
                           FLG_C_SET => s_FLG_C_SET,
                           FLG_C_CLR => s_FLG_C_CLR,
                           FLG_C_LD => s_FLG_C_LD,
                           FLG_Z_LD => s_FLG_Z_LD,
                           FLG_LD_SEL => s_FLG_LD_SEL,
                           FLG_SHAD_LD => s_FLG_SHAD_LD,
                           SP_LD => s_SP_LD,
                           SP_INCR => s_SP_INCR,
                           SP_DECR => s_SP_DECR,
                           SCR_WE => s_SCR_WE,
                           SCR_ADDR_SEL => s_SCR_ADDR_SEL,
                           SCR_DATA_SEL => s_SCR_DATA_SEL);
                           
pr_c : PC port map (FROMIMMED => s_IMMED,
                    FROMSTACK => s_SCR_OUT,
                    PCMUXSEL => s_PC_MUX_SEL,
                    clk => CLK,
                    pcld => s_PC_LD,
                    pcinc => s_PC_INC,
                    restart => s_RST,
                    pccount => s_PC_COUNT);
                    
p_r : prog_rom port map (ADDRESS => s_PC_COUNT,
                           INSTRUCTION => s_IR,
                           CLK => CLK);
      
r_f : REG_FILE port map (DIN => s_DIN,
                  ADRX => s_IR_1,
                  ADRY => s_IR_2,
                  RF_WR => s_RF_WR,
                  CLK => CLK,
                  DX_OUT => s_DX_OUT,
                  DY_OUT => s_DY_OUT);   

a_m : ALU_MUX port map (DY_OUT => s_DY_OUT,
                        IR => s_IR_8,
                        ALU_OPY_SEL => s_ALU_OPY_SEL,
                        dout => s_ALU_MUX_OUT);
                                          
ar_lu : ALU port map (SEL => s_ALU_SEL,
                      A => s_DX_OUT,
                      B => s_ALU_MUX_OUT,
                      CIN => s_Cin,
                      RESULT => s_RESULT,
                      C => s_Cout,
                      Z => s_Zout);

flags : cz_flags port map (clk => clk,
                           flg_shad_ld => s_FLG_SHAD_LD,
                           flg_z_ld => s_FLG_Z_LD,
                           Z => s_Zout,
                           flg_ld_sel => s_FLG_LD_SEL,
                           flg_c_set => s_FLG_C_SET,
                           flg_c_ld => s_FLG_C_LD,
                           C => s_Cout,
                           flg_c_clr => s_FLG_C_CLR,
                           Z_FLAG => s_Zin,
                           C_FLAG => s_Cin);
                           
                      
--c_f : C port map (Cin => s_Cout,
--                  LD => s_FLG_C_LD,
--                  SET => s_FLG_C_SET,
--                  CLK => CLK,
--                  CLR => s_FLG_C_CLR,
--                  Cout => s_Cin);
                  
--z_f : Z port map (Zin => s_Zout,
--                LD => s_FLG_Z_LD,
--                CLK => CLK,
--                Zout => s_Zin);  
                
i_f : int_f port map (clk => clk,
                      set => s_set,
                      clr => s_clr,
                      dout => s_int_f);
     
stackpointer : stack_pointer port map ( A => s_DX_OUT,
                                        CLK => CLK,
                                        RST => RESET,
                                        SP_LD => s_SP_LD,
                                        SP_INCR => s_SP_INCR,
                                        SP_DECR => s_SP_DECR,
                                        DATA_OUT => s_DATA_OUT);
                       
scratchram : scratch_ram port map ( din => s_SCR_DATA,
                                    SCR_ADDR => s_SCR_ADDR,
                                    SCR_WE => s_SCR_WE,
                                    CLK => clk,
                                    DATA_OUT => s_SCR_OUT);
                                    

OUT_PORT <= s_DX_OUT;
PORT_ID <= s_ir(7 downto 0);
            

end Behavioral;
