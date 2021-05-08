library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;
use std.env.stop;

library dot_matrix;
use dot_matrix.types.all;
use dot_matrix.constants.all;
use dot_matrix.charmap.all;

library dot_matrix_sim;
use dot_matrix_sim.sim_subprograms.all;
use dot_matrix_sim.sim_constants.all;
 
entity top_tb is
end top_tb; 
 
architecture sim of top_tb is
 
    -- DUT signals
    signal clk : std_logic := '1';
    signal rst_button : std_logic := '1'; -- Pullup
    signal uart_to_dut : std_logic := '1';
    signal uart_from_dut : std_logic;
    signal led_1 : std_logic;
    signal led_2 : std_logic;
    signal led_3 : std_logic;
    signal led_4 : std_logic;
    signal led_5 : std_logic;
    signal rows : std_logic_vector(7 downto 0);
    signal cols : std_logic_vector(7 downto 0);

    -- TB UART_TX signals
    signal uart_tx_start : std_logic := '0';
    signal uart_tx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx_busy : std_logic;

    -- LED_CONTROLLER_8X8_VC signals
    signal vc_enable_checking : boolean := false;
    signal vc_led8x8_template : matrix_type := (others => (others => '0'));
    signal vc_led8x8_output : matrix_type := (others => (others => '0'));
    signal vc_test_failed : boolean;

    -- Set to true from TCL to enable interactive mode
    signal interactive : boolean := false;

    -- Time to wait before checking the DUT output
    constant dut_reaction_time : time := 10 * clock_period;
    
    -- How long to keep checking the DUT output for each character
    constant check_cycle_time : time := 10 * full_cycle_time;

    -- Total time the TCL program should wait for each test to complete
    constant character_test_time : time := dut_reaction_time + check_cycle_time;

begin
 
    gen_clock(clk);

  DUT : entity dot_matrix.top(str)
  generic map (
    PULSE_TIME_US => sim_led_pulse_time_us,
    DEADBAND_TIME_US => sim_led_deadband_time_us
  )
  port map (
    clk => clk,
    rst_button => rst_button,
    uart_rx => uart_to_dut,
    uart_tx => uart_from_dut,
    led_1 => led_1,
    led_2 => led_2,
    led_3 => led_3,
    led_4 => led_4,
    led_5 => led_5,
    rows => rows,
    cols => cols
  );

  UART_TX : entity dot_matrix.uart_tx(rtl)
  port map (
    clk => clk,
    -- explained: VHDL 2008 way to access signals inside a module using hierachical path
    rst => << signal DUT.rst : std_logic >>,
    start => uart_tx_start,
    data => uart_tx_data,
    busy => uart_tx_busy,
    tx => uart_to_dut
  );

  VC : entity dot_matrix_sim.led_controller_8x8_vc(sim)
  generic map (
    PULSE_TIME_US => sim_led_pulse_time_us,
    DEADBAND_TIME_US => sim_led_deadband_time_us
  )
  port map (
    enable => vc_enable_checking,
    led8x8_template => vc_led8x8_template,
    led8x8_output => vc_led8x8_output,
    test_failed => vc_test_failed,
    rows => rows,
    cols => cols
  );

  PROC_SEQUENCER : process
    variable str : line;
    variable char : char_range;

    procedure check_output(constant expected_char : char_range) is
    begin
        vc_led8x8_template <= charmap(expected_char);
    
        -- Give the DUT some time to react
        wait until uart_tx_busy = '0';
        wait for dut_reaction_time;
    
        -- Check a few full render cycles for this character
        vc_enable_checking <= true;
        wait for check_cycle_time;
        vc_enable_checking <= false;
        wait for 1 ns;
    
        write(str, string'("Output:"));
        writeline(output, str);
        print_char(vc_led8x8_output);
    
    end procedure;
    
    begin

    -- Wait until the DUT is out of reset
    wait until << signal DUT.rst : std_logic >> = '0';

    if interactive then
        write(str, string'("Interactive mode enabled"));
        writeline(output, str);
   
        -- explained: we never leave this loop when we are in interactive loop
        -- explained: we have to stop the simulation manually
        while true loop
   
          -- Hand over control to TCL when UART_TX is ready
          if uart_tx_busy /= '0' then
            wait until uart_tx_busy = '0';
            stop;
          end if;
           
          -- Print the transmitted character
          -- explained: wait for the TCL script to set the uart_tx_start
          if uart_tx_start /= '1' then
            wait until uart_tx_start = '1';
          end if;
          char := to_integer(unsigned(uart_tx_data));
          report "TX: " & character'val(char);
   
          check_output(char);
   
        end loop;
    end if;
 
    -- If the interactive flag was not set (self-checking mode)
    for c in char_range loop
 
        -- Write a character to the DUT
        report "TX: " & character'val(c);
        uart_tx_data <= std_logic_vector(to_unsigned(c, uart_tx_data'length));
        -- explained: raise start for a single clock cycle
        uart_tx_start <= '1';
        wait until rising_edge(clk);
        uart_tx_start <= '0';
        wait until rising_edge(clk);
   
        check_output(c);
   
        assert not vc_test_failed severity failure;
   
    end loop;
   
    print_test_ok;
    finish;
  end process; -- PROC_SEQUENCER

end architecture;
