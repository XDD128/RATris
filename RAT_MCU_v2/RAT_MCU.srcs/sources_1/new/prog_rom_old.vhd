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
    COMPONENT prog_rom
        PORT(   ADDRESS : in std_logic_vector(9 downto 0); 
                INSTRUCTION : out std_logic_vector(17 downto 0); 
                CLK : in std_logic
    );  
    END COMPONENT;

    --Signal declarions - can be the same names as the ports
    signal ADDRESS : std_logic_vector(9 downto 0);
    signal INSTRUCTION : std_logic_vector(17 downto 0);
    signal CLK : std_logic := '0';
	--For designs with a CLK, uncomment the following
	--signal CLK : std_logic := '0';
	
	--For designs with a CLK uncomment the following
	constant CLK_period: time := 10 ns;
	
    begin
    
    process begin
        wait for 5 ns;
        CLK <= not CLK;
    end process;
      
		-- Map the UUT's ports to the signals
        uut: prog_rom PORT MAP (
            ADDRESS => ADDRESS,
            INSTRUCTION => INSTRUCTION,
            CLK => CLK
        );
    process begin
        for I in 0 to 200 loop
            ADDRESS <= std_logic_vector(to_unsigned(I, 10));
            wait for 10 ns;
        end loop;
    end process;

end Behavioral;
