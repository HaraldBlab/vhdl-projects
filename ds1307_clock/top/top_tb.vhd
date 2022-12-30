library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity top_tb is
end top_tb;

architecture sim of top_tb is

  constant clk_hz : integer := 10e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst_ext : std_logic := '0';
  signal uart_rx : std_logic;
  signal uart_tx : std_logic;
  signal uart_rx_fifo_full : std_logic;
  signal uart_rx_stop_bit_error : std_logic;
  signal rtcc_scl : std_logic;
  signal rtcc_sda : std_logic;

  -- Data received by the UART BFM
  signal recv_tdata : std_logic_vector(7 downto 0);
  signal recv_tvalid : std_logic;
  signal recv_tready : std_logic := '1';

  -- Data that the UART BFM shall send
  signal send_tdata : std_logic_vector(7 downto 0) := (others => '0');
  signal send_tvalid : std_logic := '0';
  signal send_tready : std_logic;

begin

  clk <= not clk after clk_period / 2;

  -- Pullup
  rtcc_scl <= 'H';
  rtcc_sda <= 'H';

  DUT : entity work.top(str)
  generic map (
    clk_hz => clk_hz
  )
  port map (
    clk => clk,
    rst_ext => rst_ext,
    uart_rx => uart_rx,
    uart_tx => uart_tx,
    uart_rx_fifo_full => uart_rx_fifo_full,
    uart_rx_stop_bit_error => uart_rx_stop_bit_error,
    rtcc_scl => rtcc_scl,
    rtcc_sda => rtcc_sda
  );

  UART_VVC : entity work.uart_buffered(rtl)
  generic map (
    clk_hz => clk_hz,
    baud_rate => 115200
  )
  port map (
    clk => clk,
    rst => rst_ext,
    rx => uart_tx,
    tx => uart_rx,
    recv_tdata => recv_tdata,
    recv_tvalid => recv_tvalid,
    recv_tready => recv_tready,
    send_tdata => send_tdata,
    send_tvalid => send_tvalid,
    send_tready => send_tready,
    rx_fifo_full => open,
    rx_stop_bit_error => open
  );

  SEQUENCER_PROC : process

    procedure send_word(byte : std_logic_vector(7 downto 0)) is
    begin
      send_tdata <= byte;
      send_tvalid <= '1';
      
      loop
        wait until rising_edge(clk);
        if send_tvalid = '1' and send_tready = '1' then
          exit;
        end if;
      end loop;

      send_tvalid <= '0';
      wait for 0 ns;
    end procedure;

  begin
    wait for clk_period * 2;

    rst_ext <= '0';

    wait for clk_period * 2000;
    
    send_word(x"00"); -- CMD_BUS_RST
    send_word(x"01"); -- CMD_START_CONDITION
    send_word(x"02"); -- CMD_TX_BYTE
    send_word("10101010");
    send_word(x"05"); -- CMD_STOP_CONDITION
    wait for clk_period * 50_000;

    finish;
  end process;

end architecture;