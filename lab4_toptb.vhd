--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:17:33 09/24/2011
-- Design Name:   
-- Module Name:   C:/fpgaclass/project4/lab4_toptb.vhd
-- Project Name:  project4
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lab4_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY lab4_toptb IS
END lab4_toptb;
 
ARCHITECTURE behavior OF lab4_toptb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lab4_top
    PORT(
         clk50 : IN  std_logic;
         test : IN  std_logic;
         anode : OUT  std_logic_vector(3 downto 0);
         seg7 : OUT  std_logic_vector(6 downto 0);
         btn1 : IN  std_logic;
         clk1khz : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk50 : std_logic := '0';
   signal test : std_logic := '0';
   signal btn1 : std_logic := '0';

 	--Outputs
   signal anode : std_logic_vector(3 downto 0);
   signal seg7 : std_logic_vector(6 downto 0);
   signal clk1khz : std_logic;

   -- Clock period definitions
   constant clk50_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lab4_top PORT MAP (
          clk50 => clk50,
          test => test,
          anode => anode,
          seg7 => seg7,
          btn1 => btn1,
          clk1khz => clk1khz
        );

   -- Clock process definitions
   clk50_process :process
   begin
		clk50 <= '0';
		wait for clk50_period/2;
		clk50 <= '1';
		wait for clk50_period/2;
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk50_period*10;

		btn1<='1';
		wait for 1 ms;
		btn1<='0';
      -- insert stimulus here 

      wait for 100000 ns;
		assert false
			report "End of testbench"
			severity failure;

      wait;
   end process;

END;
