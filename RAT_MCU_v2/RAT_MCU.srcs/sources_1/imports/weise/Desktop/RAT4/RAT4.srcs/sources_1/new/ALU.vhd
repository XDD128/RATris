library IEEE;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
    Port ( SEL : in STD_LOGIC_VECTOR (3 downto 0);
           A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           CIN : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0);
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

signal sA, sB, sCin : unsigned(8 downto 0);

begin

sA <= unsigned('0'&A);
sB <= unsigned('0'&B);
sCin <= "00000000"&Cin;

proc1: process(SEL, sA, sB, sCin, CIN)
    variable x_RESULT : unsigned (8 downto 0) := "000000000"; --extend result by 1 bit for carry 
    
    begin
    
    Z <= '0';
        case SEL is
            when "0000" => x_RESULT := (sA + sB) ;                 --ADD
            when "0001" => x_RESULT := (sA + sB + sCin);                 --ADDC
            when "0010" => x_RESULT := (sA - sB);                 --SUB
            when "0011" => x_RESULT := (sA - sB - sCin);                 --SUBC
            when "0100" => x_RESULT := (sA - sB);                 --CMP
            when "0101" => x_RESULT := sA AND sB;                 --AND
            when "0110" => x_RESULT := sA OR sB;                --OR
            when "0111" => x_RESULT := sA XOR sB;                 --EXOR
            when "1000" => x_RESULT := sA AND sB ;       --TEST
            when "1001" => x_RESULT :=  sA(7 downto 0) & CIN;             --LSL
            when "1010" => x_RESULT :=  sA(0) & CIN & sA(7 downto 1);                --LSR
            when "1011" => x_RESULT := sA(7 downto 0) & sA(7);                 --ROL
		    when "1100" => x_RESULT := sA(0) & sA(0) & sA(7 downto 1); -- ROR
            when "1101" => x_RESULT := sA(0) & sA(7) & sA(7 downto 1);                 --ASR
            when "1110" => x_RESULT := sB;                --MOV
            when others => x_RESULT := "000000000";
            
        end case;

--        if (x_RESULT(8) = '1') then
--          C <= '1';
--        else
--            C <= '0';
--        end if;s

        if (x_RESULT(7 downto 0) = "00000000") then
            Z <= '1';
        else
            Z <= '0';
        end if;
        
        RESULT <= std_logic_vector(x_RESULT(7 downto 0));
        C <= x_RESULT(8);
        
    end process proc1;
end Behavioral;
