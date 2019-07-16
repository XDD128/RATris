library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Z is
    Port ( Zin : in STD_LOGIC;
           LD : in STD_LOGIC;
           CLK : in STD_LOGIC;
           Zout : out STD_LOGIC);
end Z;

architecture Behavioral of Z is
    signal Z_FLAG : std_logic;
begin
    process (Z_FLAG, CLK, LD) begin
        if rising_edge(CLK) then
            if (LD = '1') then
                Z_FLAG <= Zin;
            end if;
        end if;
    end process;
    
    Zout <= Z_FLAG;

end Behavioral;
