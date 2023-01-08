library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_icestick is
  port (
    clk : in std_logic;
    rst_button : in std_logic; -- J3 connector, pin 44, pull-up
    uart_tx : out std_logic; -- USB-UART
    led : out std_logic_vector(3 downto 0); -- LED0-LED3
    scl : out std_logic; -- J1 connector, pin 112, pull-up
    sda : inout std_logic -- J1 connector, pin 113, pull-up
  );
end top_icestick;

architecture str of top_icestick is

  signal rst : std_logic;

begin

  rst <= not rst_button;
  
  led(2) <= rst; -- LD3 right (not used)
  led(3) <= '0'; -- LD4 bottom (not used)

  TOP : entity work.top(rtl)
    generic map (
      clk_hz => 12e6 -- The Lattice iCEstick oscillator is 12 MHz
    )
    port map (
      clk => clk,
      rst_ext => rst,
      uart_tx => uart_tx,
      scl => scl,
      sda => sda
    );

end architecture;