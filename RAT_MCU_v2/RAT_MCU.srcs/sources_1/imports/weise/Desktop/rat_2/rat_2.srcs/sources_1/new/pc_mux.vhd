library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_mux is
    Port ( FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
           PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
           DOUT : out STD_LOGIC_VECTOR (9 downto 0));
end pc_mux;
     
     
architecture Behavioral of pc_mux is

begin
sel : process(FROM_IMMED, FROM_STACK, PC_MUX_SEL)
begin
    case PC_MUX_SEL is
        when "00" => DOUT <= FROM_IMMED ;
        when "01" => DOUT <= FROM_STACK ;
        when "10" => DOUT <= "1111111111" ;
        when others => DOUT <= "0000000000";
    end case;
end process sel;


end Behavioral;
