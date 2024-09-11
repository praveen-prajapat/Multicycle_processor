library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 	 

entity memory is 
port(
    M_add, M_inp,M_user: in std_logic_vector(15 downto 0);
	 clock, Mem_W,reset_memory: in std_logic;
    M_data,M_out : out std_logic_vector(15 downto 0)
    );	 
end entity memory;

architecture behav of memory is
type array_of_vectors is array (31 downto 0) of std_logic_vector(15 downto 0);
signal mem_storage : array_of_vectors := (
0=>"0000000001010000",
1 => "0010000001010000",
2 => "0011000001010000",
3 => "0001000001010000",
4 => "0100000001010000",
5 => "0101000001010000",
6 => "0110000001010000",
7 => "1000000001010000",
8 => "1001000000000001",
9 => "1010000001010000",
10 => "1011000001010000",
11 => "1100000001010000",
12=>"0000000001010000",
13 => "0111000001010000",
14 => "1111000001010000",
15 => "1110000001010000",
others=>"0000000001010000"
);

-- To store the instruction registers at mem_Address(M_Add)
begin
--Writing Process
mem_write: process(clock,reset_memory)
--writing is synchronous and if Mem_W is 1 and rising_edge of the clock then we can store data at that memory address
    begin
	     if (reset_memory = '1') then
--            L1 : for i in 0 to 65535 loop
 L1 : for i in 0 to 31 loop  
                mem_storage(i) <= "0000000000000000";
            end loop L1;
				
        elsif(rising_edge(clock)) then
            if (Mem_W = '1') then
                mem_storage(to_integer(unsigned(M_add))) <= M_inp;
            else 
                null;
            end if;
        else
            null;
        end if;
    end process; 	 
	 --reading is asynchronous just the address is needed to Fetch the data.
	 
M_data <= mem_storage(to_integer(unsigned(M_add)));	 
M_out <= mem_storage(to_integer(unsigned(M_user)));

end architecture behav;