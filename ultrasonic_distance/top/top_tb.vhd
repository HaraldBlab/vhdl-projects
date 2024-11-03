library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity top_tb is
end top_tb;

architecture sim of top_tb is

  constant clk_hz : integer := 12e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal led : std_logic_vector(7 downto 0);  -- DUT out
	signal trigger : std_logic;                 -- DUT out
	signal echo : std_logic := '0';             -- DUT in

  -- echo burst at 40 kHz
  constant burst_hz : integer := 40e4;
  constant burst_period : time := 1 sec / burst_hz;
  
  constant burst_time : time := 290 us;

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.top(rtl)
  port map (
    clk => clk,
    rst_ext => rst,
    leds => led,
    trig => trigger,
    echo => echo
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;

    rst <= '0';

    wait for clk_period * 10;

    -- the ULTRA_SONIC immediately starts running - ignore first trigger
    wait until falling_edge(trigger);
    assert trigger = '0'
      report "Initial Reset triggering failed."
      severity failure;
 
    -- simulate a single ULTRA_SONIC measurement
    wait until falling_edge(trigger);
    wait until falling_edge(trigger);
    assert trigger = '0'
      report "Measurement Reset triggering failed."
      severity failure;

    echo <= '1';
    wait for  burst_time;
    echo <= '0';
    wait for burst_period;
  
    assert led = "11111111"
      report "Measurement LEDs  failed."
      severity failure;

      -- RESET_SYNC entity is tested
    -- ULTRA_SONIC entity is tested
    -- ULTRA_SONIC dons't use RESET_SYNC
    assert false
      report "We did it"
      severity warning;

    finish;
  end process;

end architecture;