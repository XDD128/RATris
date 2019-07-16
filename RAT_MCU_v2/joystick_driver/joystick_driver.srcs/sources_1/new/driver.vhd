library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity driver is
    Port ( LEFT : in STD_LOGIC;
           RIGHT : in STD_LOGIC;
           OUT_L : out STD_LOGIC;
           OUT_R : out STD_LOGIC);
end driver;

architecture Behavioral of driver is

begin

process (LEFT, RIGHT) begin
        OUT_L <= NOT(LEFT);
        OUT_R <= NOT(RIGHT);
end process;

end Behavioral;
