library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keypad_driver_top is
  Port (col : in std_logic_vector(2 downto 0);
        clk : in std_logic;
        anodes : out std_logic_vector(3 downto 0);
        cathodes : out std_logic_vector(7 downto 0);
        rows : out std_logic_vector(3 downto 0);
        int : out std_logic);
end keypad_driver_top;

architecture Behavioral of keypad_driver_top is

component driver is
    Port ( rows : out STD_LOGIC_VECTOR (3 downto 0);
           col : in STD_LOGIC_VECTOR (2 downto 0);
           clk : in STD_LOGIC;
           data : out STD_LOGIC_VECTOR (7 downto 0);
           int : out STD_LOGIC);
end component driver;

component sseg_dec is
    Port (     ALU_VAL : in std_logic_vector(7 downto 0); 
               CLK : in std_logic;
               DISP_EN : out std_logic_vector(3 downto 0);
               SEGMENTS : out std_logic_vector(7 downto 0));
end component;

signal s_data : std_logic_vector(7 downto 0);
signal s_int : std_logic;

begin

kp_driver : driver Port map (rows => rows,
                             col => col,
                             clk => clk,
                             data => s_data,
                             int => int);
                             
seven : sseg_dec Port map (ALU_VAL => s_data,
                           CLK => clk,
                           DISP_EN => anodes,
                           SEGMENTS => cathodes);

end Behavioral;
