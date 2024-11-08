-- Ugur OZGUR, Electrical Engineering Student at Istanbul Technical University
-- ozgur19@itu.edu.tr	web.itu.edu.tr/ozgur19	ugur-ozgur.gen.tr
-- May 9, 2020
-- Distance Measurement with HC-SR04
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ultrasonic is
	port(
	CLOCK: in std_logic;
	LED: out std_logic_vector(7 downto 0);
	TRIG: out std_logic;
	ECHO: in std_logic
	);
end ultrasonic;

architecture rtl of ultrasonic is

signal microseconds: std_logic := '0';	-- Added initial value
signal counter: std_logic_vector(17 downto 0) := (others => '0'); -- Added initial value
signal leds: std_logic_vector(7 downto 0) := (others => '0'); -- Added initial value
signal trigger: std_logic;

begin
	
	process(CLOCK)
	variable count0: integer range 0 to 7;
	begin
		if rising_edge(CLOCK) then
			if count0 = 5 then
				count0 := 0;
			else
				count0 := count0 + 1;
			end if;
			if count0 = 0 then
				microseconds <= not microseconds;
			end if;
		end if;
	end process;
	
	process(microseconds)
	variable count1: integer range 0 to 262143;
	begin
		if rising_edge(microseconds) then
			if count1 = 0 then
				counter <= "000000000000000000";
				trigger <= '1';
			elsif count1 = 10 then
				trigger <= '0';
			end if;
			if ECHO = '1' then
				counter <= counter + 1;
			end if;
			if count1 = 249999 then
				count1 := 0;
			else
				count1 := count1 + 1;
			end if;
		end if;
	end process;
	
	process(ECHO)
	begin
		if falling_edge(ECHO) then
			if counter < 291 then
				leds <= "11111111";
			elsif counter < 581 then
				leds <= "11111110";
			elsif counter < 871 then
				leds <= "11111100";
			elsif counter < 1161 then
				leds <= "11111000";
			elsif counter < 1451 then
				leds <= "11110000";
			elsif counter < 1741 then
				leds <= "11100000";
			elsif counter < 2031 then
				leds <= "11000000";
			elsif counter < 2321 then
				leds <= "10000000";
			else
				leds <= "00000000";
			end if;
		end if;
	end process;
	
	LED <= leds;
	TRIG <= trigger;
	
end rtl;