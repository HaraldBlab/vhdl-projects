package constants is

    -- Lattice iCEstick has a 12 MHz oscillator
    constant clock_frequency : real := 12.0e6;

    --- Baud rate for uart rx / tx to a usual (slow) value
    constant baud_rate : natural := 115200;

    -- how long each led should be lit in micorseconds
    -- note: avoid time datatype ecause not all synthesizer support it
    constant led_pulse_time_us : natural := 1000;  -- 1 / (1000e-6 * 8) = 125 Hz

    -- Deadband in microseconds subtracted from led_pulse_time_us
    constant led_deadband_time_us : natural := 10;
end package;
