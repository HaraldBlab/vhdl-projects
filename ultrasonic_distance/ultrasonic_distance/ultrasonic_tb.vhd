library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity ultrasonic_tb is
end ultrasonic_tb;

architecture sim of ultrasonic_tb is

  -- the DUT only works for 12 MHz
  constant clk_hz : integer := 12e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal led : std_logic_vector(7 downto 0);  -- DUT out
	signal trigger : std_logic;                 -- DUT out
	signal echo : std_logic := '0';             -- DUT in

  -- trigger time (not used here)
  constant time_10us : time := clk_period * 120;
  -- echo burst at 40 kHz
  constant burst_hz : integer := 40e4;
  constant burst_period : time := 1 sec / burst_hz;
  
  -- test data 
  type type_stimulus is record
    burst_time : time;                         -- the time to wait before sending the burst 
    leds       : std_logic_vector(7 downto 0); -- expected result from DUT
  end record type_stimulus;
  -- test data array
  constant stimuli_max : integer := 8; 
  type array_type_stimulus is array(0 to stimuli_max) of type_stimulus; 
  
  -- valid test pattern using magic numbers from implementation
  constant stimuli : array_type_stimulus := (
    (  290 us, "11111111"), 
    (  580 us, "11111110"), 
    (  870 us, "11111100"),
    ( 1160 us, "11111000"),
    ( 1450 us, "11110000"),
    ( 1740 us, "11100000"),
    ( 2030 us, "11000000"),
    ( 2320 us, "10000000"),
    ( 3000 us, "00000000")
    );

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.ultrasonic(rtl)
  port map (
    CLOCK => clk,
    -- rst => rst, -- the DUT doesn't support any reset logic
    LED => led,
    TRIG => trigger,
    ECHO => echo
  );

  SEQUENCER_PROC : process

  procedure validate(burst_time : in time; leds : in std_logic_vector(0 to 7)) is
  begin
    -- You only need to supply a short 10uS pulse to the trigger input to start the ranging.
    -- this is done by the DUT
    -- trigger <= '1';
    -- wait for time_10us;
    -- trigger <= '0';
    wait until rising_edge(trigger);
    -- wait for time_10us;
    wait until falling_edge(trigger);
    assert trigger = '0'
      report "reset triggering failed"
      severity failure;

    -- And then the module will send out an 8 cycle burst of ultrasound at 40 kHz and raise its echo.
    -- 8 cycle burst of ultrasound at 40 kHz is sent to the environment to detect reflections. 
    -- Simulate module 
    -- wait burst time to create distance
    echo <= '1';
    wait for  burst_time;
    echo <= '0';
    wait for burst_period;

    assert LED = leds
      report "Triggering at " & time'image(burst_time) & " failed: " & 
        " expected " & to_hex_string(leds) & 
        " actual " & to_hex_string(LED)
      severity failure;

    wait for clk_period * 10;  
  end procedure;

  variable cnt : integer := 0; 
  begin
    wait for clk_period * 2;

    -- the DUT doesn't support any reset logic
    -- testing to come ...
    rst <= '0';
    wait for clk_period * 10;
    rst <= '1';
    wait for clk_period;

    -- the DUT immediately starts running - ignore first trigger
    wait until falling_edge(trigger);
    assert trigger = '0'
      report "Reset triggering failed."
      severity failure;

    -- validate for all stimuli data
    for cnt in 0 to stimuli_max loop
      
      validate(stimuli(cnt).burst_time, stimuli(cnt).leds);

    end loop;

    assert false
      report "We did it"
      severity warning;

    finish;
  end process;

end architecture;
