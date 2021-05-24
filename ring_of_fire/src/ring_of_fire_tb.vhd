library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.finish;

entity ring_of_fire_tb is
end ring_of_fire_tb; 

architecture sim of ring_of_fire_tb is

  constant clk_hz : integer := 100e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst_n : std_logic := '0';
  signal led_1 : std_logic;
  signal led_2 : std_logic;
  signal led_3 : std_logic;
  signal led_4 : std_logic;
  signal led_5 : std_logic;

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.ring_of_fire(str)
    generic map (
      pwm_bits => 8,
      cnt_bits => 16,
      clk_cnt_len => 1
    )
    port map (
      clk => clk,
      rst_n => rst_n,
      led_1 => led_1,
      led_2 => led_2,
      led_3 => led_3,
      led_4 => led_4,
      led_5 => led_5
    );

  SEQUENCER : process
  begin
    rst_n <= '1';
    wait for 1400 us;

    report "Simulation finished. Check the waveform.";
    finish;
  end process;

end architecture;