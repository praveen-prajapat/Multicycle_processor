library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all; 

--importing libraries
entity temporary_register is
    port(
        clock, reset: in std_logic; 
        temp_data : in std_logic_vector(15 downto 0);
        temp_read : out std_logic_vector(15 downto 0);
        temp_W : in std_logic);
end entity temporary_register;
architecture behav of temporary_register is

signal store: std_logic_vector(15 downto 0):= "0000000000000000" ;
--signal to store the temp_data input and assign it simultaneously
begin 
temp_writing : process (clock,reset)
begin
   if (reset = '1') then
        store<= "0000000000000000";
		  --for writing if it is rising_edge of the clock and if reset is 1 the it is 0 
		  --and if temp_w is 1 then temp_data is alloted to store.
--   elsif (rising_edge(clock)) then
		elsif (clock ='1') then
            if (temp_w='1') then
                store<= temp_data;
					 end if;

end if;	

end process;

temp_read<=store;	
--Reading is asynchronous
end architecture behav;

