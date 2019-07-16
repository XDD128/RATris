library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity driver is
    Port ( rows : out STD_LOGIC_VECTOR (3 downto 0);
           col : in STD_LOGIC_VECTOR (2 downto 0);
           clk : in STD_LOGIC;
           data : out STD_LOGIC_VECTOR (7 downto 0);
           int : out STD_LOGIC);
end driver;

architecture Behavioral of driver is
    type state_type is (ROW0, ROW1, ROW2, ROW3);
    signal PS, NS : state_type;

begin
    process(clk) begin
        if(rising_edge(clk)) then
            PS <= NS;
        end if;
    end process;
    
    process (col, PS) begin
        rows <= "1111";
        int <= '0';
        data <= "00000000";
        case PS is
            when ROW0 =>
                rows <= "1000";
                if(col = "100") then
                    data <= "00000001"; --1
                    NS <= ROW0;
                    int <= '1';
                elsif(col = "010") then
                    data <= "00000010"; --2
                    NS <= ROW0;
                    int <= '1';
                elsif(col = "001") then
                    data <= "00000011"; --3
                    NS <= ROW0;
                    int <= '1';
                else
                    data <= "11111111"; --no output
                    NS <= ROW1;
                end if;
                
            when ROW1 =>
                rows <= "0100";
                if(col = "100") then
                    data <= "00000100"; --4
                    NS <= ROW1;
                    int <= '1';
                elsif(col = "010") then
                    data <= "00000101"; --5
                    NS <= ROW1;
                    int <= '1';
                elsif(col = "001") then --6
                    data <= "00000110";
                    NS <= ROW1;
                    int <= '1';
                else
                    data <= "11111111";
                    NS <= ROW2;
                end if;
                
            when ROW2 =>
                    rows <= "0010";
                if(col = "100") then
                    data <= "00000111"; --7
                    NS <= ROW2;
                    int <= '1';
                elsif(col = "010") then
                    data <= "00001000"; --8
                    NS <= ROW2;
                    int <= '1';
                elsif(col = "001") then
                    data <= "00001001"; --9
                    NS <= ROW2;
                    int <= '1';
                else
                    data <= "11111111";
                    NS <= ROW3;
                end if;

            when ROW3 =>
                    rows <= "0001";
                if(col = "100") then
                    data <= "00000000"; --star
                    NS <= ROW3;
                    int <= '1';
                elsif(col = "010") then
                    data <= "00000000"; --0
                    NS <= ROW3;
                    int <= '1';
                elsif(col = "001") then
                    data <= "00000000"; --#
                    NS <= ROW3;
                    int <= '1';
                else
                    data <= "11111111";
                    NS <= ROW0;
                end if;

            end case;
      end process;

end Behavioral;
