library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--make the entity name of your simulation file the same name as the file you  wish to simulate
--with the word Sim at the end of it.  The entity is empty because a simulation file does not 
--connect to anything on the board.
entity RFsim is
--  Port ( );
end RFsim;

architecture Behavioral of RFsim is

    -- Component Declaration for the Unit Under Test (UUT) (the module you are testing)
component RF is Port(
        FROM_IN : in STD_LOGIC_VECTOR (7 downto 0);
        FROM_SP : in STD_LOGIC_VECTOR (7 downto 0);
        FROM_SCR : in STD_LOGIC_VECTOR (7 downto 0);
        FROM_ALU : in STD_LOGIC_VECTOR (7 downto 0);
        RF_WR_SEL : in STD_LOGIC_VECTOR (1 downto 0);
        ADRX : in STD_LOGIC_VECTOR(4 downto 0);
        ADRY : in STD_LOGIC_VECTOR(4 downto 0);
        RF_WR : in STD_LOGIC;
        CLK : in STD_LOGIC;
        DX_OUT : out STD_LOGIC_VECTOR(7 downto 0);
        DY_OUT : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    --Signal declarions - can be the same names as the ports
    signal FROM_IN : std_logic_vector( 7 downto 0) := "00000000";
    signal FROM_SP : std_logic_vector( 7 downto 0) := "00000000";
    signal FROM_SCR : std_logic_vector( 7 downto 0) := "00000000";
    signal FROM_ALU : std_logic_vector( 7 downto 0) := "00000000";
    signal RF_WR_SEL : std_logic_vector( 1 downto 0) := "00";
    signal ADRX : std_logic_vector(4 downto 0) := "00000";
    signal ADRY : std_logic_vector(4 downto 0) := "00000";
    signal RF_WR : std_logic := '0';
    signal DX_OUT : std_logic_vector(7 downto 0);
    signal DY_OUT : std_logic_vector(7 downto 0);
	--For designs with a CLK, uncomment the following
	signal CLK : std_logic := '0';
	
	--For designs with a CLK uncomment the following
	constant CLK_period: time := 10 ns;
	
    begin
    
		-- Map the UUT's ports to the signals
        uut: RF PORT MAP (
            FROM_IN => FROM_IN,
            FROM_SP => FROM_SP,
            FROM_SCR => FROM_SCR,
            FROM_ALU => FROM_ALU,
            RF_WR_SEL => RF_WR_SEL,
            ADRX => ADRX,
            ADRY => ADRY,
            RF_WR => RF_WR,
            DX_OUT => DX_OUT,
            DY_OUT => DY_OUT,
            CLK => CLK
        );

		--For designs with a CLK uncomment the following
		--CLK_process : process
		--begin
		--	CLK <= '0';
		--	wait for CLK_period/2;
		--	CLK <= '1'; 
		--	wait for CLK_period/2;
		--end process;
		
		
        stim_proc: process
        begin
            -- now assign values to the input signals
			-- you should include at least 8 test cases for all labs that 
			-- are representative of different inputs for your circuit
			-- if you can do an exhaustive test (like those that have only 8
			-- or 16 possible input combinations) - do an exhaustive test
            FROM_IN <= "11111111";
            FROM_SP <= "00000001";
            FROM_SCR <= "00000011";
            FROM_ALU <= "00000111";
            RF_WR_SEL <= "00";
            ADRX <= "11111";
            ADRY <= "00011";
            RF_WR <= '1';
            CLK <= CLK;
            wait for 10 ns;
            FROM_IN <= "11111111";
            FROM_SP <= "00000001";
            FROM_SCR <= "00000011";
            FROM_ALU <= "00000111";
            RF_WR_SEL <= "01";
            ADRX <= "01111";
            ADRY <= "11111";
            RF_WR <= '0';
            CLK <= CLK;
            wait for 10 ns;
            FROM_IN <= "00000000";
            FROM_SP <= "00000000";
            FROM_SCR <= "00000000";
            FROM_ALU <= "00000000";
            RF_WR_SEL <= "00";
            ADRX <= "00000";
            ADRY <= "00000";
            RF_WR <= '0';
            CLK <= CLK;
            wait for 10 ns;
            FROM_IN <= "00000000";
            FROM_SP <= "00000000";
            FROM_SCR <= "00000000";
            FROM_ALU <= "00000000";
            RF_WR_SEL <= "00";
            ADRX <= "00000";
            ADRY <= "00000";
            RF_WR <= '0';
            CLK <= CLK;
            
            wait;
        end process;
end Behavioral;