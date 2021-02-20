library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is

end top_tb; 

architecture sim of top_tb is

  constant clk_hz : integer := 100;
  constant clk_period : time := 1 sec / clk_hz;
 
  signal clk : std_logic := '1';
  signal rst_n : std_logic := '0';
  signal segments : std_logic_vector(6 downto 0);
  signal digit_sel : std_logic;

begin

  -- Device under test
  DUT : entity work.top(rtl)
  generic map (
    clk_hz => clk_hz,
    alt_counter_len => 2
  )
  port map (
    clk => clk,
    rst_n => rst_n,
    segments => segments,
    digit_sel => digit_sel
  );

  CLOCK_PROC : process
  begin
    wait for clk_period / 2;
    clk <= not clk;    
  end process;

  RESET_PROC : process
  begin

    for count in 1 to 10 loop
      wait until clk = '1';
    end loop;
 
    rst_n <= '1';
    wait;
  end process;

end architecture;