library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    clk_hz : integer
  );
  port (
    clk : in std_logic;
    rst_ext : in std_logic;

    -- UART
    uart_rx : in std_logic;
    uart_tx : out std_logic;
    uart_rx_fifo_full : out std_logic;
    uart_rx_stop_bit_error : out std_logic;

    -- PmodRTCC
    rtcc_scl : out std_logic;
    rtcc_sda : inout std_logic
  );
end top;

architecture str of top is

  constant baud_rate : integer := 115200;
  constant i2c_hz : integer := 10e3;

  signal rst : std_logic;
  signal cmd_tdata : std_logic_vector(7 downto 0);
  signal cmd_tvalid : std_logic;
  signal cmd_tready : std_logic;
  signal rd_tdata : std_logic_vector(7 downto 0);
  signal rd_tvalid : std_logic;
  signal rd_tready : std_logic;

begin

  RESET_SYNC : entity work.reset_sync(rtl)
  port map (
    clk => clk,
    rst_in => rst_ext,
    rst_out => rst
  );

  UART : entity work.uart_buffered(rtl)
    generic map (
      clk_hz => clk_hz,
      baud_rate => baud_rate
    )
    port map (
      clk => clk,
      rst => rst,
      rx => uart_rx,
      tx => uart_tx,
      recv_tdata => cmd_tdata,
      recv_tvalid => cmd_tvalid,
      recv_tready => cmd_tready,
      send_tdata => rd_tdata,
      send_tvalid => rd_tvalid,
      send_tready => rd_tready,
      rx_fifo_full => uart_rx_fifo_full,
      rx_stop_bit_error => uart_rx_stop_bit_error
    );

  I2C_CONTROLLER : entity work.i2c_controller(rtl)
    generic map (
      clk_hz => clk_hz,
      i2c_hz => i2c_hz
    )
    port map (
      clk => clk,
      rst => rst,
      scl => rtcc_scl,
      sda => rtcc_sda,
      cmd_tdata => cmd_tdata,
      cmd_tvalid => cmd_tvalid,
      cmd_tready => cmd_tready,
      rd_tdata => rd_tdata,
      rd_tvalid => rd_tvalid,
      rd_tready => rd_tready,
      nack => open
    );

end architecture;