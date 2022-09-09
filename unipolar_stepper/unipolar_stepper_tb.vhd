library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity unipolar_stepper_tb is
end unipolar_stepper_tb;

architecture sim of unipolar_stepper_tb is

    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz;

    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    signal cw : std_logic := '1';
    signal coils : std_logic_vector(3 downto 0);

    constant wait_count : natural := 1;  -- 2 ms
begin

    clk <= not clk after clk_period / 2;

    DUT : entity work.unipolar_stepper(rtl)
    generic map (
        wait_count => wait_count
    )
    port map (
        clk => clk,
        rst => rst,
        cw => cw,
        coils => coils
    );

    SEQUENCER_PROC : process
        -- time used for a single step (set coils and wait)
        variable step_time : time := (wait_count + 1) * clk_period;

        procedure check_clockwise_steps is
        begin

            wait for step_time;
            assert coils = "0001"
                report "Expected coils to be '0001'"  
                severity failure;
    
            wait for step_time;
            assert coils = "0011"
                report "Expected coils to be '0011'"  
                severity failure;
    
            wait for step_time;
            assert coils = "0010"
                report "Expected coils to be '0010'"  
                severity failure;
    
            wait for step_time;
            assert coils = "0110"
                report "Expected coils to be '0110'"  
                severity failure;
        
            wait for step_time;
            assert coils = "0100"
                report "Expected coils to be '0100'"  
                severity failure;
    
            wait for step_time;
            assert coils = "1100"
                report "Expected coils to be '1100'"  
                severity failure;
        
            wait for step_time;
            assert coils = "1000"
                report "Expected coils to be '1000'"  
                severity failure;
    
            wait for step_time;
            assert coils = "1001"
                report "Expected coils to be '1001'"  
                severity failure;
                
        end procedure;

        procedure check_counterclockwise_steps is
        begin
            wait for step_time;
            assert coils = "0001"
                report "Expected coils to be '0001'"  
                severity failure;

            wait for step_time;
            assert coils = "1001"
                report "Expected coils to be '1001'"  
                severity failure;

            wait for step_time;
            assert coils = "1000"
                report "Expected coils to be '1000'"  
                severity failure;
                         
            wait for step_time;
            assert coils = "1100"
                report "Expected coils to be '1100'"  
                severity failure;

            wait for step_time;
            assert coils = "0100"
                report "Expected coils to be '0100'"  
                severity failure;

            wait for step_time;
            assert coils = "0110"
                report "Expected coils to be '0110'"  
                severity failure;

            wait for step_time;
            assert coils = "0010"
                report "Expected coils to be '0010'"  
                severity failure;
        
            wait for step_time;
            assert coils = "0011"
                report "Expected coils to be '0011'"  
                severity failure;

        end procedure;
    
        begin
        wait for clk_period;

        report "Verifing reset rst <= '1'";

        rst <= '1';

        wait for clk_period;
        assert coils = "0000"
            report "Expected coils to be '0000'"
            severity failure;

        report "Verifing reset rst <= '0'";
            
        rst <= '0';

        wait for 1*clk_period;
        assert coils = "0000"
            report "Expected coils to be '0000'"  
            severity failure;
        

        report "Verifing 8 clockwise micro steps";
        check_clockwise_steps;

        report "Verifing 8 counter clockwise micro steps";
        cw <= '0';
        check_counterclockwise_steps;

        report "Verifing multiple 8 clockwise micro steps";
        cw <= '1';
        for i in 0 to 3 loop
            check_clockwise_steps;         
        end loop;

        report "Verifing multiple 8 counter clockwise micro steps";
        cw <= '0';
        for i in 0 to 3 loop
            check_counterclockwise_steps;         
        end loop;

        report "Verifing multiple 8 sweeping  micro steps";
        for i in 0 to 3 loop
            cw <= '1';
            check_clockwise_steps;         
            cw <= '0';
            check_counterclockwise_steps;         
        end loop;

        report "Test successful!";


        finish;
    end process;

end architecture;