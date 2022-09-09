library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity top_tb is
end top_tb;

architecture sim of top_tb is

    constant clk_hz : integer := 12e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst_n : std_logic := '1';
    signal coils : std_logic_vector(3 downto 0);

    -- current direction
    signal cw: std_logic := '1';
    -- current speed (slowlyness)
    constant wait_count : natural := 24000;  -- 2 ms  wait time for the stepper        
    -- motor has 512 steps for 360 rotation
    constant steps_to_360 : natural := 512;

begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.top(rtl)
    port map (
        clk => clk,
        rst_n => rst_n,
        coils => coils
    );

    SEQUENCER_PROC : process
        variable step_time : time := (wait_count + 1) * clk_period;
        variable reset_time : time := 4 * clk_period;
    begin
        wait for clk_period * 2;

        report "Verifing reset rst_n <= '0'";

        rst_n <= '0';
        wait for reset_time;

        wait for clk_period;
        assert coils = "0000"
            report "Expected coils to be '0000'"
            severity failure;

        report "Verifing reset rst_n <= '1'";
        
        rst_n <= '1';
        wait for reset_time;

        assert coils = "0000"
            report "Expected coils to be '0000'" & 
            "actual '0x" & to_hstring(coils) & "'"
            severity failure;
    
        report "running 512 steps form 0..360";

        -- a single steps
        wait for steps_to_360 * step_time;

        assert coils = "0001"
        report "Expected coils to be '0001'" & 
        " actual '0x" & to_hstring(coils) & "'"
        severity failure;

        report "Test successful.";

        finish;
    end process;

end architecture;