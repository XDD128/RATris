library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity PC is Port (
           FROMIMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROMSTACK : in STD_LOGIC_VECTOR (9 downto 0);
           PCMUXSEL : in STD_LOGIC_VECTOR (1 downto 0);
           clk : in STD_LOGIC;
           pcld : in STD_LOGIC;
           pcinc : in STD_LOGIC;
           restart : in STD_LOGIC;
           pccount : out STD_LOGIC_VECTOR(9 downto 0));

end PC;

architecture Behavioral of PC is

component pc_mux is
    Port ( FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
           PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
           DOUT : out STD_LOGIC_VECTOR (9 downto 0));
end component;

component programCounter is
    Port ( clk : in STD_LOGIC;
           pc_ld : in STD_LOGIC;
           pc_inc : in STD_LOGIC;
           rst : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR (9 downto 0);
           pc_count : out STD_LOGIC_VECTOR(9 downto 0));
end component;

signal s_din : std_logic_vector(9 downto 0);

begin

  

progCount : programCounter port map ( clk => clk,
                                      pc_ld => pcld,
                                      pc_inc => pcinc,
                                      rst => restart,
                                      din => s_din,
                                      pc_count => pccount);
                                      
mux : pc_mux port map ( FROM_IMMED => FROMIMMED,
                        FROM_STACK => FROMSTACK,
                        PC_MUX_SEL => PCMUXSEL,
                        DOUT => s_din);

end Behavioral;
