library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity programCounter is
    Port ( clk : in STD_LOGIC;
           pc_ld : in STD_LOGIC;
           pc_inc : in STD_LOGIC;
           rst : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR (9 downto 0);
           pc_count : out STD_LOGIC_VECTOR(9 downto 0));
end programCounter;

architecture Behavioral of programCounter is
signal q : std_logic_vector(9 downto 0) := "0000000000";

begin

    process (clk)      --sync process
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then       --ouputs 0 if rst is high
                q <= "0000000000";
            elsif(pc_ld = '1') then        --outputs din if pc_ld is high
                q <= din;
            elsif(pc_inc = '1') then
                q <= std_logic_vector(unsigned(q) + 1);
            end if;
        end if;

    end process;
    pc_count <= q;           
    
end Behavioral;
