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

  constant clk_counter_bits : integer := 5;
  constant i2c_hz : integer := 100e3;
  constant baud_rate : integer := 115200;

  signal clk : std_logic := '1';
  signal rst_ext : std_logic := '0';
  signal scl : std_logic := 'H';
  signal sda : std_logic := 'H';

  signal uart_tx : std_logic;
  signal uart_bfm_data_out : std_logic_vector(7 downto 0);
  signal uart_bfm_data_out_valid : boolean;


begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.top(rtl)
  generic map (
    -- 21 bit counter wraps 5.7 times/second at 12 MHz
    clk_counter_bits => clk_counter_bits,

    -- Defaults for the Lattice iCEstick board
    clk_hz => clk_hz,
    i2c_hz => i2c_hz,
    baud_rate => baud_rate
  )
  port map (
    clk => clk,
    rst_ext => rst_ext,
    -- UART
    uart_tx => uart_tx,
    -- I2C
    scl => scl,
    sda => sda   
  );

  SEQUENCER_PROC : process
    variable wait_reset : time := 128 * clk_period;
    variable wait_data : time := 192*1024 * clk_period;

  begin
    wait for clk_period * 2;

    report "Resetting";
    rst_ext <= '0';
    wait for wait_reset;
    wait for clk_period * 2;

    report "Getting data";
    wait for wait_data;

    report "Successful test cases";

    finish;
  end process;

end architecture;