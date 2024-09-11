library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
	A: in std_logic_vector(15 downto 0);
	B: in std_logic_vector(15 downto 0);
	sel: in std_logic_vector(3 downto 0);
	X: out std_logic_vector(15 downto 0);
	C: out std_logic;
	Z: out std_logic);
end alu;

architecture a1 of alu is
--function to add using library
  function add(A: in std_logic_vector(15 downto 0);
    B: in std_logic_vector(15 downto 0))
    return std_logic_vector is
	   variable sum : std_logic_vector(15 downto 0) := (others => '0');
		variable carry : std_logic_vector(15 downto 0) := (others => '0');
    begin
		L1: for i in 0 to 15 loop
		  if i = 0 then
		    sum(i) := A(i) xor B(i) xor '0';
			 carry(i) := A(i) and B(i);
		  else 
		    sum(i) := A(i) xor B(i) xor carry(i-1);
			 carry(i) := (A(i) and B(i)) or (carry(i-1) and (A(i) xor B(i)));
		  end if;
		end loop L1;
		--the highest bit of carry is used as a Carry signal.
    return carry(15) & sum;
  end add;
  
  
--function to multiply
function multiply(A: in std_logic_vector(15 downto 0);
                  B: in std_logic_vector(15 downto 0))
  return std_logic_vector is
    variable product : signed(31 downto 0) := (others => '0');
    variable overflow_flag : std_logic := '0';
  begin
    product := signed(A) * signed(B);
     overflow_flag :=(product(31) or product(30) or product(29) or product(28) or product(27) or product(26) or product(25) or product(24) or product(23) or product(22) or
  product(21) or product(20) or product(19) or product(18) or product(17) or product(16));
  -- if the any of the bits higher than 16 is 1 then there is a carry in the system so overflow_flag checks that
    return overflow_flag & std_logic_vector(product(15 downto 0));
  end multiply;



function ORAB(A: in std_logic_vector(15 downto 0);
                  B: in std_logic_vector(15 downto 0))
  return std_logic_vector is
    variable orofab : std_logic_vector(15 downto 0) := (others => '0');
  begin
    for i in 0 to 15 loop
        orofab(i) := (A(i) or B(i));
    end loop;
	 --function to take OR of A and B
    return orofab(15 downto 0);
  end  orab;
  
function andab(A: in std_logic_vector(15 downto 0);
                  B: in std_logic_vector(15 downto 0))
  return std_logic_vector is
    variable andofab : std_logic_vector(15 downto 0) := (others => '0');
  begin
    for i in 0 to 15 loop
        andofab(i) := (A(i) and B(i));
    end loop;
    return andofab(15 downto 0);
	 -- function to find the And Of A and B
  end  andab;  
  
function aimplyb(A: in std_logic_vector(15 downto 0);
                  B: in std_logic_vector(15 downto 0))
  return std_logic_vector is
    variable implyofab : std_logic_vector(15 downto 0) := (others => '0');
  begin
    for i in 0 to 15 loop
        implyofab(i) := ((not A(i)) or B(i));
    end loop;
    return implyofab(15 downto 0);
  end  aimplyb;
  -- function to find A imply B

begin

alu_proc: process(A, B, sel)    -- redundant clock
 
-- temp signal to store the operation value and then it will be assigned to Output
variable temp: std_logic_vector(16 downto 0) := (others => '0');
variable twos_complement_B: std_logic_vector(15 downto 0) := (others => '0'); 
variable twos_complement_B2: std_logic_vector(16 downto 0) := (others => '0');
-- for subtraction B's complement is to be found out.
begin

    if sel="0000" then 
      temp := add(A,B);
		--perform addition
	   X<= temp(15 downto 0);
	   C <= temp(16);
		-- checking the zero flag and assign to Z
		--and highest bit is alloted to C 
		if temp(15 downto 0)="0000000000000000" then
		  Z<='1';
		else
		  Z<='0';
		end if;
		
		
    elsif sel="0010" then
	   twos_complement_B := not (B);
      twos_complement_B2 := add(twos_complement_B , "0000000000000001");
      temp := add(A,twos_complement_B2(15 downto 0));
		--take twos complement of B and add to A hence subtract
		X<=temp(15 downto 0);
		C<=temp(16);
		-- checking the zero flag and assign to Z
		--and highest bit is alloted to C 
		if temp(15 downto 0)="0000000000000000" then
		  Z<='1';
		else
		  Z <='0';
		end if;
		
		
    elsif sel="0011" then
      temp := multiply(A,B);
		--perform multiplication
		X <= temp(15 downto 0);
		C <= temp(16);
		-- checking the zero flag and assign to Z
		--and highest bit is alloted to C 
	   if temp(15 downto 0)="0000000000000000" then
		  Z <= '1';
	   else
	     Z <= '0';
	   end if;
		
		
		elsif sel="0100" then
      temp := '0' & andab(A,B);
		--perform and of a and b 
		X <= temp(15 downto 0);
		C <= '0';
		--No need of carry here 
	   if temp(15 downto 0)="0000000000000000" then
		  Z <= '1';
	   else
	     Z <= '0';
	   end if;
		
		
		elsif sel="0101" then
      temp := '0' & orab(A,B);
		--perform or of a and b
		X <= temp(15 downto 0);
		C <= '0';
		--No need of carry here 
	   if temp(15 downto 0)="0000000000000000" then
		  Z <= '1';
	   else
	     Z <= '0';
	   end if;
		
		elsif sel="0110" then
      temp := '0' & aimplyb(A,B);
		--perform imply of a and b
		X <= temp(15 downto 0);
		C <= '0';
		--No need of carry here 
	   if temp(15 downto 0)="0000000000000000" then
		  Z <= '1';
	   else
	     Z <= '0';
	   end if;
		
    else
      null;
    end if;
	
end process;

end a1;