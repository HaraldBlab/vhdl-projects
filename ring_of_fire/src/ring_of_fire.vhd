library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Fits the Lattice iCEstick FPGA board
entity ring_of_fire is
  generic (
    
    -- PWM and duty cycle counter bit length
    pwm_bits : integer := 8;

    -- Sawtooth counter bit length
    cnt_bits : integer := 25;

    -- PWM clock divider max count
    -- pwm_freq = 12 MHz / (2**8 - 1) / 47 = 1001 Hz
    clk_cnt_len : positive := 47
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic; -- Pullup

    led_1 : out std_logic;
    led_2 : out std_logic;
    led_3 : out std_logic;
    led_4 : out std_logic;
    led_5 : out std_logic
  );
end ring_of_fire;

architecture str of ring_of_fire is

  signal rst : std_logic;
  signal cnt : unsigned(cnt_bits - 1 downto 0);
  signal pwm_out : std_logic;
  signal duty_cycle : unsigned(pwm_bits - 1 downto 0);

  -- Use MSBs of counter for sine ROM address input
  alias addr is cnt(cnt'high downto cnt'length - pwm_bits);

begin

  -- Pulse all the red color LED
  -- Deactivate the red color LEDs on the iCEstick
  led_1 <= pwm_out;
  led_2 <= pwm_out;
  led_3 <= pwm_out;
  led_4 <= pwm_out;

  -- show the green color Power-on LED
  led_5 <= '1';

  RESET : entity work.reset(rtl)
    port map (
      clk => clk,
      rst_n => rst_n,
      rst => rst
    );

  PWM : entity work.pwm(rtl)
    generic map (
      pwm_bits => pwm_bits,
      clk_cnt_len => clk_cnt_len
    )
    port map (
      clk => clk,
      rst => rst,
      duty_cycle => duty_cycle,
      pwm_out => pwm_out
    );

  COUNTER : entity work.counter(rtl)
    generic map (
      counter_bits => cnt'length
    )
    port map (
      clk => clk,
      rst => rst,
      count_enable => '1',
      counter => cnt
    );

  SINE_ROM : entity work.sine_rom(rtl)
    generic map (
      data_bits => pwm_bits,
      addr_bits => pwm_bits
    )
    port map (
      clk => clk,
      addr => addr,
      data => duty_cycle
    );

end architecture;