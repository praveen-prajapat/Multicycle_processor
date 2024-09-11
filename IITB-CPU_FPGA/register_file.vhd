library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all; 
entity register_file is 
port(
    clock, RF_W,reset : in std_logic;
    A1, A2, A3,A4 ,A5: in std_logic_vector(2 downto 0);
    D3 : in std_logic_vector(15 downto 0);
    D1, D2,D4,D5: out std_logic_vector(15 downto 0));
end entity register_file;

architecture behav of register_file is
type reg_array_type is array (7 downto 0) of std_logic_vector(15 downto 0);
signal registers : reg_array_type := (0 => "0000000000001000",
1 => "0000000000001000",2 => "0000000000000000",
3 => "0000000000000100",4 => "0000000000000101",
5 => "0000000000000101",6 => "0000000000000111",
7 => "0000000000000000");
--having 7 signals to store the register files
begin 
--writing is synchronous and it is sensitive to RF_w  and if RF_w is 1 then the D3 is alloted at A3 
--finally at A3 the data is written
RF_writing : process(clock,reset)
    begin
	     if (reset = '1') then
            L1 : for i in 0 to 7 loop
                registers(i) <= "0000000000000000";
            end loop L1;
				
        elsif(rising_edge(clock)) then
--		  elsif (clock ='1') then
			if (RF_W = '1') then
                registers(to_integer(unsigned(A3))) <= D3;
            else
                null;
            end if;
			else
            null;
        end if;
end process RF_writing;
--Reading is asynchronous just the Address A is needed.
D1 <= registers(to_integer(unsigned(A1)));
D2 <= registers(to_integer(unsigned(A2)));
D4 <= registers(to_integer(unsigned(A4)));
D5 <= registers(to_integer(unsigned(A5)));
end architecture behav;