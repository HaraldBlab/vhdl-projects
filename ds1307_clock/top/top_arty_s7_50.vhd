library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_arty_s7_50 is
  port (
    CLK100MHZ : in std_logic;
    ck_rst : in std_logic; -- Negative reset connected to RESET button
    uart_txd_in : in std_logic; -- USB-UART
    uart_rxd_out : out std_logic; -- USB-UART
    led : out std_logic_vector(3 downto 0); -- LED2-LED5
    jc_2 : out std_logic; -- JC Pmod connector pin 3 (SCL)
    jc_3 : inout std_logic -- JC Pmod connector pin 7 (SDA)
  );
end top_arty_s7_50;

architecture str of top_arty_s7_50 is

  signal rst : std_logic;

begin

  rst <= not ck_rst;
  
  led(2) <= '0'; -- LD4
  led(3) <= '0'; -- LD5

  TOP : entity work.top(str)
    generic map (
      clk_hz => 100e6
    )
    port map (
      clk => CLK100MHZ,
      rst_ext => rst,
      uart_rx => uart_txd_in,
      uart_tx => uart_rxd_out,
      uart_rx_fifo_full => led(0), -- LD2
      uart_rx_stop_bit_error => led(1), -- LD3
      rtcc_scl => jc_2,
      rtcc_sda => jc_3
    );

end architecture;