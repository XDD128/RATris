library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Scratch_RAM is
    Port ( DIN : in STD_LOGIC_VECTOR(9 downto 0);
           SCR_ADDR : in STD_LOGIC_VECTOR(7 downto 0);
           SCR_WE : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR(9 downto 0));
end Scratch_RAM;

architecture Behavioral of Scratch_RAM is
TYPE memory is ARRAY (0 to 255) of STD_LOGIC_VECTOR (9 downto 0);
SIGNAL ram : memory := (others => (others => '0')); -- Create an instance of a 256x10 ARRAY

begin
DATA_OUT <= ram(to_integer(unsigned(SCR_ADDR))); --output value of register whose address was inputted
upd: process(CLK)
begin
-- Write to the register when write enable is 1 and on a rising clock edge
    if rising_edge(CLK) then
        if SCR_WE = '1' then
            ram(to_integer(unsigned(SCR_ADDR))) <= DIN;
        end if;
    end if;
end process upd; 

end Behavioral;
