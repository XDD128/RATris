library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity C is
    Port ( Cin : in STD_LOGIC;
           LD : in STD_LOGIC;
           SET : in STD_LOGIC;
           CLK : in STD_LOGIC;
           CLR : in STD_LOGIC;
           Cout : out STD_LOGIC);
end C;

architecture Behavioral of C is
signal C_FLAG : std_logic;
begin
    process (CLK) begin
        if rising_edge (CLK) then
            if (CLR = '1') then
                C_FLAG <= '0';
            elsif (SET = '1') then 
                C_FLAG <= '1';
            elsif (LD = '1') then
                C_FLAG <= Cin;
            end if;
        end if;
    end process;
    
    Cout <= C_FLAG;
   
end Behavioral;
