library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity stack_pointer is
  Port (
    A : in std_logic_vector(7 downto 0);
    CLK : in std_logic;
    RST : in std_logic;
    SP_LD : in std_logic;
    SP_INCR : in std_logic;
    SP_DECR : in std_logic;
    DATA_OUT : out std_logic_vector(7 downto 0));
end stack_pointer;

architecture Behavioral of stack_pointer is
signal q : std_logic_vector(7 downto 0) := "00000000";

begin

    process(clk) begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                q <= "11111111";
            elsif(SP_LD = '1') then
                q <= A;
            elsif(SP_INCR = '1') then
                q <= std_logic_vector(unsigned(q) + 1);
            elsif(SP_DECR = '1') then
                q <= std_logic_vector(unsigned(q) - 1);
            end if;
         end if;
    end process;

DATA_OUT <= q;

end Behavioral;
