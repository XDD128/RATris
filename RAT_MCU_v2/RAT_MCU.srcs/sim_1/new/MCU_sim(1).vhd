library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--make the entity name of your simulation file the same name as the file you  wish to simulate
--with the word Sim at the end of it.  The entity is empty because a simulation file does not 
--connect to anything on the board.
entity MCUsim is
--  Port ( );
end MCUsim;

architecture Behavioral of MCUsim is

    -- Component Declaration for the Unit Under Test (UUT) (the module you are testing)
component MCU is
        Port ( IN_PORT : in STD_LOGIC_VECTOR (7 downto 0);
               RESET : in STD_LOGIC;
               INT : in STD_LOGIC;
               CLK : in STD_LOGIC;
               OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
               PORT_ID : out STD_LOGIC_VECTOR (7 downto 0);
               IO_STRB : out STD_LOGIC);
    end component;


    --Signal declarions - can be the same names as the ports
    signal IN_PORT : std_logic_vector(7 downto 0) := "00000000";
    signal RESET : std_logic := '0';
    signal INT : std_logic := '0';
    signal OUT_PORT : std_logic_vector(7 downto 0);
    signal PORT_ID : std_logic_vector(7 downto 0);
    signal IO_STRB : std_logic;
	--For designs with a CLK, uncomment the following
	signal CLK : std_logic := '0';
	
	--For designs with a CLK uncomment the following
	constant CLK_period: time := 10 ns;
	
    begin
    
		-- Map the UUT's ports to the signals
        uut: MCU PORT MAP (
            IN_PORT => IN_PORT,
            RESET => RESET,
            INT => INT,
            OUT_PORT => OUT_PORT,
            PORT_ID => PORT_ID,
            IO_STRB => IO_STRB,
            clk => clk
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
            IN_PORT <= "00000000";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "00000001";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "00001111";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "11111111";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "00000000";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "01000000";
            RESET <= '0';
            INT <= '0';
            wait for 10 ns;
            IN_PORT <= "00000111";
            RESET <= '0';
            INT <= '0';
wait;
        end process;
end Behavioral;