library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity int_f is
    Port ( clk : in STD_LOGIC;
           set : in STD_LOGIC;
           clr : in STD_LOGIC;
           dout : out STD_LOGIC);
end int_f;

architecture Behavioral of int_f is

begin

    process (set, clr, clk) begin
        if(rising_edge(clk)) then
            if(clr = '1') then
                dout <= '0';
            elsif(set = '1') then
                dout <= '1';
            end if;
        end if;
    end process;

end Behavioral;
