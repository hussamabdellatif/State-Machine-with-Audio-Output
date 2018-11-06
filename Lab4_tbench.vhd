--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:41:24 10/11/2017
-- Design Name:   
-- Module Name:   C:/Users/cfritz/Documents/Personal/EE478F17/lab4/Lab4/Lab4_tbench.vhd
-- Project Name:  Lab4
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Lab4
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
 
ENTITY Lab4_tbench IS
END Lab4_tbench;
 
ARCHITECTURE behavior OF Lab4_tbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Lab4
    PORT(
         clk : IN  std_logic;
         n_reset : IN  std_logic;
         SDATA_IN : IN  std_logic;
         BIT_CLK : IN  std_logic;
         SOURCE : IN  std_logic_vector(2 downto 0);
         VOLUME : IN  std_logic_vector(4 downto 0);
         START : IN  std_logic;
         SYNC : OUT  std_logic;
         SDATA_OUT : OUT  std_logic;
         AC97_n_RESET : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal n_reset : std_logic := '0';
   signal SDATA_IN : std_logic := '0';
   signal BIT_CLK : std_logic := '0';
   signal SOURCE : std_logic_vector(2 downto 0) := "100";
   signal VOLUME : std_logic_vector(4 downto 0) := (others => '1');
   signal START : std_logic := '0';

 	--Outputs 
   signal SYNC : std_logic;
   signal SDATA_OUT : std_logic;
   signal AC97_n_RESET : std_logic; 

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant BIT_CLK_period : time := 81.4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Lab4 PORT MAP (
          clk => clk,
          n_reset => n_reset,
          SDATA_IN => SDATA_IN,
          BIT_CLK => BIT_CLK,
          SOURCE => SOURCE,
          VOLUME => VOLUME,
          START => START,
          SYNC => SYNC,
          SDATA_OUT => SDATA_OUT,
          AC97_n_RESET => AC97_n_RESET
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   BIT_CLK_process :process
   begin
		BIT_CLK <= '0';
		wait for BIT_CLK_period/2;
		BIT_CLK <= '1';
		wait for BIT_CLK_period/2;
   end process;
 
	process(BIT_CLK)
	begin	
		SDATA_IN <= BIT_CLK;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		n_reset <= '1';

      wait for clk_period*10;
		START <= '1';

      wait;
   end process;

END;
