library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity ads1115_reader_tb is
end ads1115_reader_tb;

architecture sim of ads1115_reader_tb is

  procedure print(msg : string) is
    variable l : line;
  begin
    write(l, to_string(now) & " - " & msg);
    writeline(output, l);
  end procedure;

  constant clk_hz : integer := 12e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  -- I2C
  signal scl : std_logic := 'H';
  signal sda : std_logic := 'H';
  -- ADS1115 configuration register
  constant config_lsb : std_logic_vector(7 downto 0) := x"C4";
  constant config_msb : std_logic_vector(7 downto 0) := x"83";
  constant config : std_logic_vector(15 downto 0) := config_msb & config_lsb;
  -- reader handling
  signal ready : std_logic := '0';
  signal valid : std_logic := '0';
  signal data: std_logic_vector(15 downto 0) := (others => 'X');

begin

  clk <= not clk after clk_period / 2;

  DUT : entity work.ads1115_reader(rtl)
  port map (
    clk => clk,
    rst => rst,
    -- configuation
    config => config,
    -- AXI style
    ready => ready,
    valid => valid,
    data => data
  );

  SEQUENCER_PROC : process

    procedure read_value is
    begin
      report "Reading value with ADS1115 reader";
      ready <= '1';
      
      loop
        wait until rising_edge(clk);
        if valid = '1' and ready = '1' then
          print("Received value from READER: " & to_string(data));
          ready <= '0';
          exit;
        end if;
      end loop;
    end procedure;

    procedure read_wait is
    begin
      ready <= '1';
      wait for clk_period;
  
      report "Running samples";
  
      wait for 11000 us;
  
      ready <= '0';
      wait for clk_period;
    end procedure;

  begin
    wait for clk_period * 2;

    ready <= '0';
    -- valid <= '0';
    
    rst <= '0';

    wait for clk_period * 10;

--    read_wait;
    read_value;
    wait for clk_period * 10;
    read_value;
    wait for clk_period * 10;

    finish;
  end process;

end architecture;