library std;
library ieee;
use ieee.std_logic_1164.all;
entity Testbench is
end entity;

architecture Behave of Testbench is
--Signal for Clock in Testbench 
signal clock : std_logic:= '0';
signal input_user : std_logic_vector(7 downto 0);
signal output : std_logic_vector(7 downto 0);
signal res: std_logic:= '0';
signal resm: std_logic:= '0';
signal count: integer:=0;

component CPU is
    port (clk_1hz:in std_logic;
		input_user: in std_logic_vector(7 downto 0);
		output:out std_logic_vector(7 downto 0)
    );
end component;
begin

clock<= not clock after 5 ns;
--e<= not e after 150ns;
--process(input_user,clock)
--begin
--count<=count+1;
--if(count=1) then
--input_user<="00000000";
--elsif(count=2) then 
--input_user<="00000001";
--elsif(count=3) then 
--input_user<="00000010";
--elsif(count=4) then 
--input_user<="00000011";
--elsif(count=5) then
--input_user<="00000100";
--elsif(count=6) then
--input_user<="00000101";
--elsif(count=7) then
--input_user<="00000110";
--elsif(count=8) then
--input_user<="00000111";
--end if;
--end process;

input_user<="00000111" ,"00000100" after 60 ns;
dut_instance:  CPU port map(
      clock,
		input_user,
		output
    );
--Instantiating the component and give the clock and reset and we can see the signals as testbench outputs.
end Behave;