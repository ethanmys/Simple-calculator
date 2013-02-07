----------------------------------------------------------------------------------
--Name: Chuan Lim Kho
-- Design overview: Simple calculator
-- Design name: Project 4
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab4_top is
port(
		clk50:in std_logic;
		sliderswitches: in std_logic_vector(7 downto 0);
		anode: out std_logic_vector(3 downto 0);
		seg7: out std_logic_vector(7 downto 0);
		pushbuttons: in std_logic_vector(3 downto 0));


end lab4_top;

architecture Behavioral of lab4_top is
signal intclk: std_logic :='0'; --- internal clk signal
signal dig1,dig2,dig3,dig4: std_logic_vector(3 downto 0):="0000"; --signal from debounce to 7seg
signal HEX: STD_LOGIC_VECTOR (3 downto 0); --input for 7seg
signal operatora: std_logic_vector(3 downto 0);--temp for sliderswitch
signal shiftemp: std_logic_vector(1 downto 0); --temp register for operation 0-5
signal forbool: std_logic_vector(2 downto 0); ---for boolean opcode 13
signal opa: std_logic_vector(3 downto 0); --operand a
signal opb: std_logic_vector(3 downto 0); --operand b
signal temps: std_logic_vector(7 downto 0); --temp for computation
signal prevres: std_logic_vector(7 downto 0); --temp for storage of previous result
-----------------constant value for opcode---------------------
constant opcode0: std_logic_vector(3 downto 0):= "0000";
constant opcode1: std_logic_vector(3 downto 0):= "0001";
constant opcode2: std_logic_vector(3 downto 0):= "0010";
constant opcode3: std_logic_vector(3 downto 0):= "0011";
constant opcode4: std_logic_vector(3 downto 0):= "0100";
constant opcode5: std_logic_vector(3 downto 0):= "0101";
constant opcode6: std_logic_vector(3 downto 0):= "0110";
constant opcode7: std_logic_vector(3 downto 0):= "0111";
constant opcode8: std_logic_vector(3 downto 0):= "1000";
constant opcode9: std_logic_vector(3 downto 0):= "1001";
constant opcode10: std_logic_vector(3 downto 0):= "1010";
constant opcode11: std_logic_vector(3 downto 0):= "1011";
constant opcode12: std_logic_vector(3 downto 0):= "1100";
constant opcode13: std_logic_vector(3 downto 0):= "1101";
constant opcode14: std_logic_vector(3 downto 0):= "1110";
constant opcode15: std_logic_vector(3 downto 0):= "1111";
----------------------------------------------------------------

begin
--------------------------------button debouncing circuit -------------------
PROCESS (intclk,pushbuttons,sliderswitches)
variable cnt: integer:=0; --for debounce circuit
variable result: std_logic; --variable for opcode10
variable i: integer; --variable for opcode 10 loop

  BEGIN
    IF pushbuttons = "0000" THEN
      cnt :=0;
    ELSIF (intclk'EVENT AND intclk = '1') THEN
-----pushbutton1------	 
		if cnt =50 and pushbuttons="0001"  then
			opa <=sliderswitches(3)&sliderswitches(2)&sliderswitches(1)&sliderswitches(0);
			opb <=sliderswitches(7)&sliderswitches(6)&sliderswitches(5)&sliderswitches(4);
			dig1 <=sliderswitches(3)&sliderswitches(2)&sliderswitches(1)&sliderswitches(0); --show display pressed
			dig2 <=sliderswitches(7)&sliderswitches(6)&sliderswitches(5)&sliderswitches(4); --show display pressed
			cnt := 0;
-----pushbutton 2------			
		elsif cnt =50 and pushbuttons="0010"  then
			operatora<=sliderswitches(7)&sliderswitches(6)&sliderswitches(5)&sliderswitches(4);
			shiftemp<=sliderswitches(1)&sliderswitches(0);
			forbool<=sliderswitches(2)&sliderswitches(1)&sliderswitches(0);
			dig1 <=sliderswitches(3)&sliderswitches(2)&sliderswitches(1)&sliderswitches(0); --show display pressed
			dig2 <=sliderswitches(7)&sliderswitches(6)&sliderswitches(5)&sliderswitches(4); --show display pressed
			cnt := 0;
			case operatora is
				when opcode0=> --shift left
					temps<=STD_LOGIC_VECTOR((shift_left(resize(unsigned(opa),8),to_integer(UNSIGNED(shiftemp)))));
				when opcode1=> --shift right
					temps<=STD_LOGIC_VECTOR((shift_right(resize(unsigned(opa),8),to_integer(UNSIGNED(shiftemp)))));
				when opcode2=> --bit clear
					if shiftemp="00" then
						temps<=std_logic_vector(resize(unsigned(opa and "1110"),8));
					elsif shiftemp="01" then 
						temps<=std_logic_vector(resize(unsigned(opa and "1101"),8));
					elsif shiftemp="10" then
						temps<=std_logic_vector(resize(unsigned(opa and "1011"),8));
					elsif shiftemp="11" then
						temps<=std_logic_vector(resize(unsigned(opa and "0111"),8));
					else 
						temps<="00000000";
					end if;
				when opcode3=> --bit set
					if shiftemp="00" then
						temps<=std_logic_vector(resize(unsigned(opa or "0001"),8));
					elsif shiftemp="01" then 
						temps<=std_logic_vector(resize(unsigned(opa or "0010"),8));
					elsif shiftemp="10" then
						temps<=std_logic_vector(resize(unsigned(opa or "0100"),8));
					elsif shiftemp="11" then
						temps<=std_logic_vector(resize(unsigned(opa or "1000"),8));
					else 
						temps<="00000000";
					end if;
				when opcode4=> --ROTL
					temps<=STD_LOGIC_VECTOR((rotate_left(resize(unsigned(opa),8),to_integer(UNSIGNED(shiftemp)))));
				when opcode5=> --ROTR
					temps<=STD_LOGIC_VECTOR((rotate_right(resize(unsigned(opa),8),to_integer(UNSIGNED(shiftemp)))));	
				when opcode6=> --MUL
					temps<=std_logic_vector(unsigned(opa)*unsigned(opb));
				when opcode7=> --add with previous result 
					temps<=std_logic_vector(resize(unsigned(opa),8)+unsigned(prevres));
				when opcode8=> --ADD
					temps<=std_logic_vector(resize(unsigned(opa),8)+unsigned(opb));
				when opcode9=> --SUB
					temps<=std_logic_vector(resize(unsigned(opb),8)-unsigned(opa));
				when opcode10=> --parity bit
					result :='0';
					for i in 3 downto 0 loop
						result :=result xor opa(i);
					end loop;
				--determining even or odd for parity bit display
					
					if result='0' then----if even
						temps<="00000000";
					elsif result='1' then --if odd
						temps<="00000001";
					else
						temps<="11111111";
					end if;

				when opcode11=> --NOP
					temps<="00000000";
				when opcode12=> --MAXAB
					if opa>opb then
						temps<=std_logic_vector(resize(unsigned(opa),8));
					elsif opa<opb then 
						temps<=std_logic_vector(resize(unsigned(opb),8));
					else 
						temps<=std_logic_vector(resize(unsigned(opb),8));
					end if;
				when opcode13=> --boolean 
					if forbool="000" then 
						temps<=std_logic_vector(resize(unsigned(not opa),8));
					elsif forbool="001" then
						temps<=std_logic_vector(resize(unsigned(opa and opb),8));
					elsif forbool="010" then
						temps<=std_logic_vector(resize(unsigned(opa or opb),8));
					elsif forbool="011" then
						temps<=std_logic_vector(resize(unsigned(opa xor opb),8));
					elsif forbool="100" then
						temps<=std_logic_vector(resize(unsigned(opa nand opb),8));
					elsif forbool="101" then
						temps<=std_logic_vector(resize(unsigned(opa nor opb),8));
					elsif forbool="110" then
						temps<=std_logic_vector(resize(unsigned(opa xnor opb),8));
					elsif forbool="111" then
						temps<="00000000";
					end if;
				when opcode14=> --NOP
					temps<="00000000";
				when opcode15=> --NOP
					temps<="00000000";
				when others =>
					temps<="00000000";
			end case;
			
-----------pushbutton3------------------
		elsif cnt =50 and pushbuttons="0100"  then
					prevres<=temps;--store previous value
					dig1<=temps(3)&temps(2)&temps(1)&temps(0);
					dig2<=temps(7)&temps(6)&temps(5)&temps(4);
					dig3<="0000"; ---not using, just initialize to zero
					dig4<="0000"; ---not using, just initialize to zero				
					cnt := 0;
-------------pushbutton 4---------------
		elsif cnt =50 and pushbuttons="1000"  then
			operatora<="0000";
			temps<="00000000";
			opa<="0000";
			opb<="0000";
			cnt := 0;
		elsif cnt /=51 and (pushbuttons="0001" or pushbuttons="0010" or pushbuttons="0100" or pushbuttons="1000") THEN 
			cnt := cnt + 1;
	   END IF;
    END IF;
  END PROCESS;
-----------------------------------------------------------------------

---------------50 Mhz to 1khz clock----------------
divclk:process(clk50)
variable counter:integer:=0;
begin
   if clk50'event and clk50='1' then  
		counter:=counter+1;
		if counter=50000 then
			intclk<= not intclk;
			counter:=0;
		end if;
	end if;
end process divclk;
----------------------------------------------------
-----------------------------------------------------

----------toggling anode-------------------------
Process(intclk) 
variable c: integer range 0 to 3; 
begin 
If intclk'event and intclk='1' then 
	if c= 3 then
		c:=0;
	else	
		c:=c+1;
	end if;

case c is
	when 0 => anode<="1110";
		hex<=dig1;
	when 1 => anode<="1101";
		hex<=dig2;
	when 2 => anode<="1011";
		hex<=dig3;
	when 3 => anode<="0111";
		hex<=dig4;
	end case;
end if;
end process;
--HEX-to-seven-segment decoder
--   HEX:   in    STD_LOGIC_VECTOR (3 downto 0);
--   seg7:   out   STD_LOGIC_VECTOR (7 downto 0);
-- 
-- segment encoinputg
--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
   
    with HEX SELect
   seg7<="11111001" when "0001",   --1
         "10100100" when "0010",   --2
         "10110000" when "0011",   --3
         "10011001" when "0100",   --4
         "10010010" when "0101",   --5
         "10000010" when "0110",   --6
         "11111000" when "0111",   --7
         "10000000" when "1000",   --8
         "10010000" when "1001",   --9
         "10001000" when "1010",   --A
         "10000011" when "1011",   --b
         "11000110" when "1100",   --C
         "10100001" when "1101",   --d
         "10000110" when "1110",   --E
         "10001110" when "1111",   --F
         "11000000" when others;   --0

end Behavioral;

