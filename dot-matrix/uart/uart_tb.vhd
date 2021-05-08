library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
use std.env.finish;
 
library dot_matrix;
 
library dot_matrix_sim;
use dot_matrix_sim.sim_subprograms.all;
use dot_matrix_sim.sim_fifo.all;
use dot_matrix_sim.sim_constants.all;

entity uart_tb is
end uart_tb; 
 
architecture sim of uart_tb is
 
  -- common signals
  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal tx_rx : std_logic := '1';

  -- UART_TX signals
  signal tx_start : std_logic := '0';
  signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_busy : std_logic;

  -- UART_RX signals
  signal rx_data : std_logic_vector(7 downto 0);
  signal rx_valid : std_logic;
  signal rx_stop_bit_error : std_logic;

  -- TB fifo for storing the transmitted characters
  shared variable fifo : sim_fifo;
begin
 
  gen_clock(clk);

  UART_TX : entity dot_matrix.uart_tx(rtl)
  port map (
    clk => clk,
    rst => rst,
    start => tx_start,
    data => tx_data,
    busy => tx_busy,
    tx => tx_rx
  );

  UART_RX : entity dot_matrix.uart_rx(rtl)
  port map (
    clk => clk,
    rst => rst,
    rx => tx_rx,
    data => rx_data,
    valid => rx_valid,
    stop_bit_error => rx_stop_bit_error
  );


  PROC_SEQUENCER : process

    -- Start the transmission of one character and add it to the TB FIFO
    procedure transmit(constant data : std_logic_vector(tx_data'range)) is
      begin
        tx_start <= '1';
        tx_data <= data;
        fifo.push(to_integer(unsigned(data)));
        wait until rising_edge(clk);
        report "Transmit: " & integer'image(to_integer(unsigned(data)));
        tx_start <= '0';
        -- give it some value to easily find out if we read data when it is not expected to do so.
        tx_data <= (others => 'X');
        wait until rising_edge(clk);

      end procedure;

    procedure wait_until_fifo_empty is
      begin
        while not fifo.empty loop
          wait until rising_edge(clk);
        end loop;
      end procedure;

    variable tx_data_var : tx_data'subtype := (others => '0');

  begin
 
    -- Reset strobe
    wait for 10 * clock_period;
    rst <= '0';

    -- Wait until UART_TX is ready
    wait until tx_busy = '0';

    -- Test all possible input values
    loop
      transmit(tx_data_var);

      -- Wait until UART_TX is done
      wait until tx_busy = '0';

      tx_data_var := std_logic_vector(unsigned(tx_data_var) + 1);

      -- exit the loop if all bits are zero
      -- explained: value wrapped to the start value
      if (unsigned(tx_data_var) = 0) then
        exit;
      end if;
    end loop;

    -- Wait until UART_RX is done
    wait_until_fifo_empty;

    -- Add a pause to check that there is no more output
    wait for 1 ms;
  
    -- Check that the stop bit error signal is working
    transmit(x"00");
    wait until tx_rx = '0';
    tx_rx <= force '0'; -- Creating a stop bit error
    wait_until_fifo_empty;
    assert rx_stop_bit_error = '1'
      report "Stop bit error signal was not asserted"
      severity failure;
  
    -- Release the stop bit error and check that the DUT recovers
    tx_rx <= release;
    wait for 1 ms;
    transmit(x"00");
    wait_until_fifo_empty;
    assert rx_stop_bit_error = '0'
      report "Stop bit error signal is still asserted"
      severity failure; 

    print_test_ok;
    finish;
      
  end process; -- PROC_SEQUENCER

  PROC_CHECK_RX : process
    variable expected : integer;
  begin
    wait until rx_valid = '1';
    
    -- Get the next transmitted word from FIFO
    expected := fifo.pop;
    
    assert to_integer(unsigned(rx_data)) = expected
      report "Output from UART_RX (" & integer'image(to_integer(unsigned(rx_data))) & 
          ") doesn't match transmitted word (" & integer'image(expected) & ")"
      severity failure;

    report "Received: " & integer'image(expected);
  end process; -- PROC_SEQUENCER

  end architecture;
