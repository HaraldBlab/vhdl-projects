library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_icestick is
  port (
    clk : in std_logic;
    rst_button : in std_logic; -- J3 connector, pin 44, pull-up
    uart_rx : in std_logic; -- USB-UART
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

  TOP : entity work.top(str)
    generic map (
      clk_hz => 12e6 -- The Lattice iCEstick oscillator is 12 MHz
    )
    port map (
      clk => clk,
      rst_ext => rst,
      uart_rx => uart_rx,
      uart_tx => uart_tx,
      uart_rx_fifo_full => led(0), -- LD1 - left
      uart_rx_stop_bit_error => led(1), -- LD2 - top
      rtcc_scl => scl,
      rtcc_sda => sda
    );

end architecture;