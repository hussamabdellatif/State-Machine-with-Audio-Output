library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Spar6_Parts.all;	


-- Top level design entity to demonstrate commnicaton with the codec
-- on the Atlys board.
entity Lab4 is
    Port ( clk : in  STD_LOGIC;
           n_reset : in  STD_LOGIC;
			  SDATA_IN : in STD_LOGIC;
			  BIT_CLK : in STD_LOGIC;
			  SOURCE : in STD_LOGIC_VECTOR(2 downto 0);
			  VOLUME : in STD_LOGIC_VECTOR(4 downto 0);
			  START : in STD_LOGIC;
			  SYNC : out STD_LOGIC;
			  SDATA_OUT : out STD_LOGIC;
			  AC97_n_RESET : out STD_LOGIC
			  );
end Lab4;


architecture arch of Lab4 is
	--Signals for connecting the codec controller to the ac97 device
	signal L_bus, R_bus, L_bus_out, R_bus_out : std_logic_vector(17 downto 0);	
	signal cmd_addr : std_logic_vector(7 downto 0);
	signal cmd_data : std_logic_vector(15 downto 0);
	signal ready : std_logic;
	signal latching_cmd : std_logic;
	
	--Clock cycle counts for 200Hz, 400Hz, 800Hz, 1600Hz
	constant COUNT_C5  : unsigned(6 downto 0) := to_unsigned(92, 7);  --48KHz audio rate, 523Hz signal
	constant COUNT_E5  : unsigned(6 downto 0) := to_unsigned(73, 7); 
	constant COUNT_G5  : unsigned(6 downto 0) := to_unsigned(61, 7); 
	constant COUNT_C6  : unsigned(6 downto 0) := to_unsigned(46, 7); 
	
	--Signals for generating the audio square wave
	signal tone_counter : unsigned(6 downto 0) := (others => '0');
	signal tone_terminal_count : unsigned(6 downto 0) := (others => '0');
	signal tone_sq_wave : std_logic := '0';
	
	--Add your signals for the slow clock and the state machine here
	signal slow_clk : std_logic := '0';
	signal slow_clk_count : unsigned(26 downto 0) := (others =>'0');
	signal state_num : unsigned(2 downto 0);
	


begin
		
	-- INSTANTIATE BOTH THE MAIN DRIVER AND AC97 CHIP CONFIGURATION STATE-MACHINE 
	-------------------------------------------------------------------------------
	ac97_cont0 : entity work.ac97(arch)
		port map(n_reset => n_reset, clk => clk, ac97_sdata_out => SDATA_OUT, 
			ac97_sdata_in => SDATA_IN, latching_cmd => latching_cmd,
			ac97_sync => SYNC, ac97_bitclk => BIT_CLK, 
			ac97_n_reset => AC97_n_RESET, ac97_ready_sig => ready,
			L_out => L_bus, R_out => R_bus, 
			L_in => L_bus_out, R_in => R_bus_out, 
			cmd_addr => cmd_addr, cmd_data => cmd_data);
 
   ac97cmd_cont0 : entity work.ac97cmd(arch)
	   port map (clk => clk, ac97_ready_sig => ready, 
	   		cmd_addr => cmd_addr, cmd_data => cmd_data, 
	   		volume => VOLUME, source => SOURCE, 
			latching_cmd => latching_cmd);  
	 

    --Generate a square wave of the correct frequency. 
	 tone_sq_wave <= '0' when tone_counter < tone_terminal_count / 2 else '1';
	 L_bus <= (others => '0') when tone_sq_wave = '0' else "000011111111111111";
	 R_bus <= (others => '0') when tone_sq_wave = '0' else "000011111111111111";

		
	 tone_counter_proc : process(clk)
	 begin
		if rising_edge(clk) then
			if ready = '1' then
				if tone_counter >= tone_terminal_count then
					tone_counter <= (others => '0');
				else
					tone_counter <= tone_counter + 1;
				end if;
			end if;
		end if;
	end process;
	 
	 --Add your code for slow clock and state machine here
	slow_clk_proc : process(clk)
	begin
		if rising_edge(clk) then
			if slow_clk_count = 1000000 then
				slow_clk <='1';
				slow_clk_count <= (others=>'0');
			else
				slow_clk <= '0';
				slow_clk_count <= slow_clk_count + 1;
			end if;
		end if;
	end process;
	
	state_machine_proc : process(slow_clk)
	begin
		if slow_clk'event and slow_clk = '1' then
			if START = '1' then state_num <= "001";
			else
				if state_num >= 1 and state_num < 5 then
				state_num <= state_num + 1;
				else state_num <= "000";
				end if;
			end if;
		end if;
	end process;
	
	process(state_num)
	begin
	case state_num is
			when "000" => tone_terminal_count <= (others=>'0');
			when "001" => tone_terminal_count <= COUNT_C5;
			when "010" => tone_terminal_count <= COUNT_E5;
			when "011" => tone_terminal_count <= COUNT_C6;
			when "100" => tone_terminal_count <= COUNT_G5;
			when others => tone_terminal_count <= (others=>'0');
		end case;
	end process;
end arch;
