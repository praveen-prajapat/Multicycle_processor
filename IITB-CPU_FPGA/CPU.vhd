library IEEE;
use ieee.std_logic_1164.all;
library work;
use work.Gates.all;

entity CPU is
    port (clk_1hz:in std_logic;
		input_user: in std_logic_vector(7 downto 0);
		output:out std_logic_vector(7 downto 0)
    );
end CPU;

architecture bhv of CPU is
component alu is
		port (
						A: in std_logic_vector(15 downto 0);
						B: in std_logic_vector(15 downto 0);
						sel: in std_logic_vector(3 downto 0);
						X: out std_logic_vector(15 downto 0);
						C: out std_logic;
						Z: out std_logic);
end component;

component se7 is
		port (A: in std_logic_vector(8 downto 0);
				outp: out std_logic_vector(15 downto 0));
end component;
	
component se10 is
		port (A: in std_logic_vector(5 downto 0);
				outp: out std_logic_vector(15 downto 0));
end component;
	
component temporary_register is
		port (clock, reset: in std_logic; 
        temp_data : in std_logic_vector(15 downto 0);
        temp_read : out std_logic_vector(15 downto 0);
        temp_W : in std_logic);
end component;
		
component register_file is 
port(
    clock, RF_W,reset : in std_logic;
    A1, A2, A3,A4,A5 : in std_logic_vector(2 downto 0);
    D3 : in std_logic_vector(15 downto 0);
    D1, D2,D4,D5: out std_logic_vector(15 downto 0));
end component;

component memory is 
		port(
			 M_add, M_inp ,M_user: in std_logic_vector(15 downto 0);
			 M_data,M_out : out std_logic_vector(15 downto 0);
			 clock, Mem_W ,reset_memory: in std_logic);
end component;
--Signals used


type state is (s1
,s2,s3,s4,s10,s12,s13,s14,s5,s7,s8,s6,s9,s11,s15
);

signal state_present,state_next:state:=s1;
    --alu signals
signal alu_A, alu_B: std_logic_vector(15 downto 0) := (others => '0');
signal alu_C: std_logic_vector(15 downto 0) := (others => '0');
signal sel: std_logic_vector(3 downto 0) := (others => '0');
signal Zero, Carry,res,resm: std_logic := '0';
signal reset,e: std_logic := '0';

-- Memory signals
signal M_add, M_inp,M_user: std_logic_vector(15 downto 0) := (others => '0');
signal M_data,M_out: std_logic_vector(15 downto 0) := (others => '0');
signal Mem_W , clock: std_logic := '0';
-- Register file signal
signal RF_W: std_logic := '0';
signal A1, A2, A3, A4,A5: std_logic_vector(2 downto 0) := (others => '1');
signal D3: std_logic_vector(15 downto 0) := (others => '0');
signal D1, D2, D4,D5: std_logic_vector(15 downto 0) := (others => '0');
-- Se7
signal se7_in: std_logic_vector(8 downto 0) := (others => '0');
signal se7_out: std_logic_vector(15 downto 0) := (others => '0');
-- Se10
signal se10_in: std_logic_vector(5 downto 0) := (others => '0');
signal se10_out: std_logic_vector(15 downto 0) := (others => '0');
signal state_curr:std_logic_vector(3 downto 0);
-- Temp
signal t1_in, t2_in, t3_in, t4_in,PC_in: std_logic_vector(15 downto 0) := (others => '0');
signal t1_op, t2_op, t3_op, t4_op, IR_op, IR_in,PC_op: std_logic_vector(15 downto 0) := (others => '0');
signal t1_w, t2_w, t3_w, t4_w, IR_w,PC_w: std_logic := '0'; 
begin



-- Instantiation of the components as given in the port map diagram

rf: register_file port map(clock, RF_W,res,A1, A2, A3 ,A4, A5, D3, D1, D2, D4, D5);
clock<=clk_1hz ;	
memory_main: memory port map (M_add, M_inp,M_user,M_data,M_out ,clock, Mem_W ,resm);			 	 
t1: temporary_register port map(clock, res, t1_in, t1_op, t1_w);
t2: temporary_register port map(clock, res, t2_in, t2_op, t2_w);
t3: temporary_register port map(clock, res, t3_in, t3_op, t3_w);
t4: temporary_register port map(clock, res, t4_in, t4_op, t4_w);
IR: temporary_register port map(clock, res, IR_in, IR_op, IR_w);
PC_temp: temporary_register port map(clock, res, PC_in, PC_op, PC_w);
alu_main: alu 	port map (alu_A,alu_B,sel,alu_C,Carry,Zero);
se7_main: se7 port map(se7_in,se7_out);
se10_main: se10 port map(se10_in,se10_out);	  
		

		
--Clock process
clk_process: process(clock,res)
	begin
            if (res = '1') then
                state_present <= s1;
            elsif (clock ='1') then
            state_present <= state_next;
            else
                Null;
            end if;                  
end process;


output_process: process(state_present,clock,res,resm,input_user,state_next,IR_op,M_data,se7_out,se10_out,alu_A,alu_B,alu_C)
	begin
        t1_w<='0';
        t2_w<='0';
        t3_w<='0';
        t4_w<='0';
        IR_w<='0';
		  PC_w<='0';
        RF_W<='0';
        Mem_W<='0';
		  
case state_present is
when s1=>
		 A4<="111";--Point at R7.
         M_add<=D4;
		 PC_in<=D4;
		 PC_w<='1';
		 IR_in<=M_data;
       --Fetch the Memory Data
		 IR_w<='1';
		 alu_A<=D4;
         alu_B<="0000000000000001"; 
		 sel<="0000";
        -- Update R7
         D3<=alu_C;
			 A3<="111";
	    	 state_curr<="0001"; --Always go to state 2 always 
		                                     state_next<=s2;		
              
                                				  --Address											 
when s2=>
		  RF_w<='1';
		  --The A3 and D3 is ready RF_w writes it in R7
          A1<=IR_op(11 downto 9);
          A2<=IR_op(8 downto 6);--signal 
		  --Fetch data in T1 and T2
		  if(IR_op(11 downto 9)="111") then
		    T1_in<=PC_op;
		  else 
		    T1_in<=D1;
		  end if;
		  if(IR_op(8 downto 6)="111") then
		    T2_in<=PC_op;
		  else 
		    T2_in<=D2;
		  end if;
		  T1_W<='1';
		  T2_W<='1';
		   state_curr<="0010";
        
                                          -- On the basis of op code in each of the corresponding code
												case IR_op(15 downto 12) is
												     when "1101" =>  state_next <= s9;
													  when "1000" =>  state_next <= s6;
													  when "1001" =>  state_next <= s10;
													  when "1110" =>  state_next <= s1;
													  when "0111" =>  state_next <= s1;
													  when "1011" => state_next <= s5;
													  when "0001" => state_next <= s5;
													  when "1010" => state_next <= s5;
													  when "1111" => state_next <= s9;
													  when "1100" => state_next <= s12;
													  when others => state_next <= s3;
												 end case;



			 
when s3=>     
	   alu_A<=T1_op;
       alu_B<=T2_op;
	   sel<=IR_op(15 downto 12);
       T3_in<=alu_C;
		 T3_W<='1';
		  state_curr<="0011";
       -- Use the ALU to perform the operation involved 
		                                state_next<=s4;
												  --Always go to s4 to update the register involved 
														



when s4=>
        if (IR_op( 15 downto 12)="1111") then
                A3<=IR_op(11 downto 9);
					 D3<=T3_op;
					 
        elsif (IR_op( 15 downto 12)="1101") then
                A3<=IR_op(11 downto 9);
					 D3<=T3_op;
					 
					 
        elsif (IR_op( 15 downto 12)="0001") then
                A3<=IR_op(8 downto 6);
					 D3<=T3_op;
					 
					 
        elsif (IR_op( 15 downto 12)="1000") then
                A3<=IR_op(11 downto 9);
					 D3<=T3_op;
					 
					 
        elsif (IR_op( 15 downto 12)="1001") then
                A3<=IR_op(11 downto 9);
					D3<=T3_op; 
					 
        elsif (IR_op( 15 downto 12)="1010") then
                A3<=IR_op(11 downto 9);
                D3<=T4_op;					 
        else    
            A3<=IR_op(5 downto 3);
				D3<=T3_op;
        end if; 
 		  --Use the OP_code to get the Address to be updated
        
		  Rf_W<='1';
		   state_curr<="0100";

			
--                 output<= pc_op(7 downto 0);
											case IR_op(15 downto 12) is
												 when "1111" => state_next <= s15;
												 when "1101" => state_next <= s14;
												 when others => 
												       state_next <= s1;                   
											  end case;
											  


when s10=>
       se7_in<='0'&IR_op( 7 downto 0);
       T3_in<=se7_out;
		 T3_w<='1';
		  state_curr<="1010";
		 --to sign extend and store in a register to be used in next state                          
                                   --move to s4 always from this state

		                             state_next<=s4;
											  


														
when s6=>
       
       se7_in<='0'&IR_op(7 downto 0);
       alu_A<=se7_out;
       alu_B<="0000000100000000";
		 sel<="0011";
       T3_in<=alu_C;
		 T3_w<='1';
		 state_curr<="0110";
       --To shift we by 8 bits multiply by 2^8 using the select 0011 to Multiply


		                             state_next<=s4;
											  --Address



														
		 
when s12=>
       
       alu_A<=T1_op;
       alu_B<=T2_op;
	   sel<= "0010";
		 state_curr<="1100";
       -- For BEQ to subtract T1 and T2
		                        --Based on op_code and Zero Flag='1' move to the state needed 


		                        case IR_op(15 downto 12) is
												when "1100" =>
													if Zero='1' then 
													  state_next<=s13;
													else
													  state_next<=s1;
													end if;
													when others => state_next <= s1;
												end case;	
												--Address


														
when s13=>
        se10_in<=IR_op(5 downto 0);
        alu_A<=se10_out;
        alu_B<="0000000000000010";
		sel<="0011";
        --To do IMM*2 use the select as multiply and store in T3
        T4_in<=alu_C;
		  T4_w<='1';
		   state_curr<="1101";
                                   --move to s9 always from s13

		                             state_next<=s9;
											  --Address


when s9=>
		 A4<="111";
       alu_A<=D4;
       alu_B<="0000000000000001";
		 sel<="0010";
       T3_in<=alu_C;
		 T3_w<='1';
		  state_curr<="1001";
		 -- Do PC-1 to take the updated PC one step back
                                  -- On the basis of Op-code move to required state
												case IR_op(15 downto 12) is
												 when "1111" => state_next <= s4;
												 when "1101" => state_next <= s4;

												 when "1100" => state_next <= s11;
												 when others => state_next <= s1;
												
												end case;	

												
	
when s11=>
         alu_A<=T3_op;
         alu_B<=t4_op;
		 sel<="0000";
		 A3<="111";
         D3<=alu_C;
		 RF_w<='1';
		  state_curr<="1011";
		 -- To do PC+IMM*2 
--                                      --Go back to S1

		                                state_next<=s1;		
										--Address

		  
		 
when s14=>
 
         se7_in<=IR_op(8 downto 0);
         alu_A<=se7_out;
         alu_B<="0000000000000010";
		 sel<="0011";
       
         T4_in<=alu_C;
		 T4_w<='1';
		 state_curr<="1110";
		 --  To do IMM*2 here IMM is 9 bits

                                       --move to s11 always from s14
                                       state_next<=s11;
														--Address


														
													
		 
when s15=>
	
			 A3<="111";
			 D3<=T2_op;
			 RF_w<='1';
		    state_curr<="1111";
		 --TO branch to the data at JLR  
                                        --move to s1 always.


		                                  state_next<=s1;	
							--Address

						 
		  
when s7=>
        
          M_add<=T3_op;
          T4_in<=M_data;
		    T4_w<='1';
		    state_curr<="0111";
         --To load the data from the given regB+IMM*2
			                               --move to next state s4 always
		                                  state_next<=s4;

			 
when s5=>
      
			 if (IR_op(15 downto 12)="0001") then
				alu_A<=T1_op;
			 elsif (IR_op(15 downto 12)="1010") then
			 alu_A<=T2_op;
			 elsif (IR_op(15 downto 12)="1011") then
			 alu_A<=T2_op;
			 else
				NUll;
			 end if;
		 -- To load Data from regA or regB based on the instruction 
         se10_in<=IR_op(5 downto 0);
         alu_B<=se10_out;
		   sel<="0000";
         T3_in<=alu_C;
			T3_w<='1';
		   state_curr<="0101";
	                              case IR_op(15 downto 12) is
												  when "0001" => state_next <= s4;
												  when "1010" => state_next <= s7;
												  when "1011" => state_next <= s8;
												  when others => state_next <= s1;			
												  end case;			

		 
when s8=> 
        M_add<=T3_op;
        M_inp<=T1_op;
		  Mem_W<='1';
	     state_curr<="1000";
		                                state_next<=s1;	

												  
when others=>
		                                state_next <= s1;	
												  
end case;	

end process;


final:process(input_user,clock,M_user,M_out,D5,A5,Carry,Zero)
begin
M_user<="00000000000"&input_user(7 downto 3);
A5<=input_user(5 downto 3);

if(input_user(2 downto 0)="000") then
output<="0000000"&clock;
elsif(input_user(2 downto 0)="001") then
output<="0000000"&Zero;
elsif(input_user(2 downto 0)="010") then
output<="0000000"&Carry;
elsif(input_user(2 downto 0)="011") then
output<="0000"&state_curr;

elsif(input_user(2 downto 0)="100") then
output<=D5(7 downto 0);
elsif(input_user(2 downto 0)="101") then
output<=D5(15 downto 8);
elsif(input_user(2 downto 0)="110") then
output<=M_out(7 downto 0);
elsif(input_user(2 downto 0)="111") then
output<=M_out(15 downto 8);
end if;
end process;

end architecture;