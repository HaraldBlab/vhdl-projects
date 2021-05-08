library dot_matrix;
use dot_matrix.constants.all;

package sim_constants is

    constant clock_period : time := 1 sec / clock_frequency;

    -- Shorter durations used for speeding up simulation time
    constant sim_led_pulse_time_us : natural := 2;
    constant sim_led_deadband_time_us : natural := 1;
 
    -- The time needed for cycling all the LEDs
    constant full_cycle_time : time := sim_led_pulse_time_us * 1 us * 8;

end package;
