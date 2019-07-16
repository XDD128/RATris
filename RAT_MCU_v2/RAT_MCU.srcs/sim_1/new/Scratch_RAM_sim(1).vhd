library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Scratch_RAM_sim is
--  Port ( );
end Scratch_RAM_sim;

architecture Behavioral of Scratch_RAM_sim is

component Scratch_RAM is
        Port ( DIN : in STD_LOGIC_VECTOR(9 downto 0);
               SCR_ADDR : in STD_LOGIC_VECTOR(7 downto 0);
               SCR_WE : in STD_LOGIC;
               CLK : in STD_LOGIC;
               DATA_OUT : out STD_LOGIC_VECTOR(9 downto 0));
    end component;

             signal  clk :  STD_LOGIC := '0';
             signal  din : STD_LOGIC_VECTOR(9 downto 0);
             signal  scr_addr :  STD_LOGIC_VECTOR(7 downto 0);
             signal  scr_we :  STD_LOGIC;
             signal  data_out :  STD_LOGIC_VECTOR (9 downto 0);
    constant CLK_period: time := 10 ns;

    begin

    process begin
        wait for 5 ns;
        CLK <= not CLK;
    end process;

        uut: Scratch_RAM PORT MAP (
            clk => clk,
            scr_addr => scr_addr,
            scr_we => scr_we,
            data_out => data_out,
            DIN => DIN
        );
process begin
            din <= "0101010101";
            scr_addr <= "01101111";
            scr_we <= '0';
            wait for 10 ns;
            din <= "0101010101";
            scr_addr <= "01101111";
            scr_we <= '1';
            wait for 10 ns;
            din <= "0000001111";
            scr_addr <= "01101111";
            scr_we <= '0';
            wait for 10 ns;
            din <= "0000001111";
            scr_addr <= "01101111";
            scr_we <= '1';
            wait for 10 ns;
            din <= "1111000011";
            scr_addr <= "01101111";
            scr_we <= '1';
            wait for 10 ns;
            din <= "1100000011";
            scr_addr <= "00000011";
            scr_we <= '0';
            wait for 10 ns;
            din <= "1100000011";
            scr_addr <= "00001111";
            scr_we <= '1';
            wait for 10 ns;
            din <= "0000000001";
            scr_addr <= "00100000";
            scr_we <= '1';
            wait for 10 ns;
      end process;
end Behavioral;