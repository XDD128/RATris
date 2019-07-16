library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cz_flags is
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
end cz_flags;

architecture Behavioral of cz_flags is

signal s_c : std_logic;
signal s_z : std_logic;

signal s_c_mux : std_logic; --output of C mux, input to C flag
signal s_z_mux : std_logic; --output of Z mux, input to Z flag

signal s_shad_c : std_logic; --shad C flag
signal s_shad_z : std_logic; --shad Z flag

begin

    process (flg_ld_sel) begin --mux's for C and Z input
        if(flg_ld_sel = '0') then
            s_c_mux <= C;
            s_z_mux <= Z;
        else
            s_c_mux <= s_shad_c;
            s_z_mux <= s_shad_z;
        end if;
    end process;
    
    process (CLK) begin --sets C flag
        if(rising_edge(clk)) then
            if(flg_c_clr = '1') then
                s_c <= '0';
            elsif(flg_c_set = '1') then
                s_c <= '1';
            elsif(flg_c_ld = '1') then
                s_c <= s_c_mux;
            end if;
        end if;
    end process;
    
    process (CLK) begin --sets Z flag
        if(rising_edge(clk)) then
            if(flg_z_ld = '1') then
                s_z <= s_z_mux;
            end if;
        end if;
    end process;
    
    process(clk) begin --sets C and Z shadow flags
        if(rising_edge(clk)) then
            if(flg_shad_ld = '1') then
                s_shad_c <= s_c;
                s_shad_z <= s_z;
             end if;
        end if;
     end process;

    C_FLAG <= s_c; --C output
    Z_FLAG <= s_z; --Z output
    
end Behavioral;
