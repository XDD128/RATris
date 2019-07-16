library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--make the entity name of your simulation file the same name as the file you  wish to simulate
--with the word Sim at the end of it.  The entity is empty because a simulation file does not 
--connect to anything on the board.
entity RAT_Wrapper_sim is
--  Port ( );
end RAT_Wrapper_sim;

architecture Behavioral of RAT_Wrapper_sim is

    -- Component Declaration for the Unit Under Test (UUT) (the module you are testing)
component RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           RST      : in    STD_LOGIC;
           INT      : in    STD_LOGIC;
           CLK      : in    STD_LOGIC;
           ANODES   : out   STD_LOGIC_VECTOR(3 downto 0);
           CATHODES : out   STD_LOGIC_VECTOR(7 downto 0));
end component;


    --Signal declarions - can be the same names as the ports
    signal SWITCHES : std_logic_vector(7 downto 0);
    signal RST : std_logic := '0';
    signal INT : std_logic := '0';
    signal LEDS : std_logic_vector(7 downto 0);
    signal CATHODES : std_logic_vector(7 downto 0);
    signal ANODES : std_logic_vector(3 downto 0);
	--For designs with a CLK, uncomment the following
	signal CLK : std_logic := '0';
	
	--For designs with a CLK uncomment the following
	constant CLK_period: time := 10 ns;
	
    begin
    
		-- Map the UUT's ports to the signals
        uut: RAT_wrapper PORT MAP (
                                 LEDS     => LEDS,
               SWITCHES => SWITCHES,
               RST      => RST,
               INT      => INT,
               CLK      => CLK,
               ANODES    => ANODES,
               CATHODES  => CATHODES
        );

		--For designs with a CLK uncomment the following
		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        stim_proc: process
        begin
            -- now assign values to the input signals
			-- you should include at least 8 test cases for all labs that 
			-- are representative of different inputs for your circuit
			-- if you can do an exhaustive test (like those that have only 8
			-- or 16 possible input combinations) - do an exhaustive test

            INT <= '0';
            wait for 900 ns;
            INT <= '1';
            
wait;
        end process;
end Behavioral;