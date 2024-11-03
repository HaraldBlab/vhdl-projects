library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    clk : in std_logic;
    rst_ext : in std_logic;
    leds: out std_logic_vector(7 downto 0);
    trig: out std_logic;
    echo: in std_logic
    );
end top;

architecture rtl of top is

  signal rst : std_logic;

begin

  RESET_SYNC : entity work.reset_sync(rtl)
  port map (
    clk => clk,
    rst_in => rst_ext,
    rst_out => rst
  );

  ULTRA_SONIC : entity work.ultrasonic(rtl)
    port map(
      CLOCK => clk,
      LED => leds,
      TRIG => trig,
      ECHO => echo
    );

end architecture;