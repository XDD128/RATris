----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2018 03:45:09 PM
-- Design Name: 
-- Module Name: REG_FILE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity REG_FILE is
    Port ( DIN : in STD_LOGIC_VECTOR(7 downto 0);
           ADRX : in STD_LOGIC_VECTOR(4 downto 0);
           ADRY : in STD_LOGIC_VECTOR(4 downto 0);
           RF_WR : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DX_OUT : out STD_LOGIC_VECTOR(7 downto 0);
           DY_OUT : out STD_LOGIC_VECTOR(7 downto 0));
end REG_FILE;

architecture Behavioral of REG_FILE is
-- Create an instance of a 32x8 ARRAY, representing 32 registers of 8 bit width.
TYPE memory is ARRAY (0 to 31) of STD_LOGIC_VECTOR (7 downto 0);
SIGNAL ram : memory := (others => (others => '0'));

begin
-- Always assign register values to outputs.
DX_OUT <= ram(to_integer(unsigned(ADRX)));
DY_OUT <= ram(to_integer(unsigned(ADRY)));

upd: process(CLK)
begin
--/ Write to register ADRX when write enable is '1' and on a rising CLK edge.
    if rising_edge(CLK) then
        if RF_WR = '1' then
            ram(to_integer(unsigned(ADRX))) <= DIN;
        end if;
    end if;
end process upd; 

end Behavioral;
