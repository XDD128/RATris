library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--make the entity name of your simulation file the same name as the file you  wish to simulate
--with the word Sim at the end of it.  The entity is empty because a simulation file does not 
--connect to anything on the board.
entity simulation is
--  Port ( );
end simulation;














architecture Behavioral of simulation is

    -- Component Declaration for the Unit Under Test (UUT) (the module you are testing)
    COMPONENT REG_FILE
        PORT( DIN : in STD_LOGIC_VECTOR(7 downto 0);
               ADRX : in STD_LOGIC_VECTOR(4 downto 0);
               ADRY : in STD_LOGIC_VECTOR(4 downto 0);
               RF_WR : in STD_LOGIC;
               CLK : in STD_LOGIC;
               DX_OUT : out STD_LOGIC_VECTOR(7 downto 0);
               DY_OUT : out STD_LOGIC_VECTOR(7 downto 0));
               
    END COMPONENT;

    --Signal declarions - can be the same names as the ports
             signal  clk :  STD_LOGIC := '0';
             signal  DX_OUT : STD_LOGIC_VECTOR(7 downto 0);
             signal  DY_OUT :  STD_LOGIC_VECTOR(7 downto 0);
             signal  RF_WR :  STD_LOGIC;
             signal  DIN :  STD_LOGIC_VECTOR (7 downto 0);
             signal ADRX:  STD_LOGIC_VECTOR(4 downto 0);
             signal ADRY:  STD_LOGIC_VECTOR(4 downto 0);
	--For designs with a CLK, uncomment the following
	--signal CLK : std_logic := '0';
	
	--For designs with a CLK uncomment the following
	constant CLK_period: time := 10 ns;
	
    begin
    
    process begin
        wait for 10 ns;
        CLK <= not CLK;
    end process;
      
		-- Map the UUT's ports to the signals
        uut: REG_FILE PORT MAP (
            clk => clk,
            RF_WR => RF_WR,
            ADRX => ADRX,
            ADRY => ADRY,
            DIN => DIN,
            DX_OUT => DX_OUT,
            DY_OUT => DY_OUT
        );
    process begin
    RF_WR <= '0';
    ADRX <= "11111";
    ADRY <= "00000";
    DIN <= "11111111";
    wait for 20 ns;
    RF_WR <= '1';
    wait for 20 ns;
    wait for 20 ns;
    DIN <= "01010101";
    ADRX <= "00000";
    ADRY <= "11111";
    wait for 20 ns;
    RF_WR <= '0';
    ADRX <= "00010";
    wait for 20 ns;
end process;

end Behavioral;
