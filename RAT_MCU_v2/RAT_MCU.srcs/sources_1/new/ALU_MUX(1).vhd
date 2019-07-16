library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_MUX is
    Port(DY_OUT : in std_logic_vector(7 downto 0);
         IR : in std_logic_vector(7 downto 0);
         ALU_OPY_SEL : in std_logic;
         dout : out std_logic_vector(7 downto 0));
end ALU_MUX;

architecture Behavioral of ALU_MUX is

begin
sel : process(DY_OUT, IR, ALU_OPY_SEL)
begin
    case ALU_OPY_SEL is
        when '0' => DOUT <= DY_OUT ;
        when '1' => DOUT <= IR ;
        when others => dout <= "00000000";
    end case;
end process sel;


end Behavioral;
