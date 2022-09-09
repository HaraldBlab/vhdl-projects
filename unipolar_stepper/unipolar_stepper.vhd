library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.ALL;    -- step = step + 1

-- an unipolar stepper motor with 4 coils
-- rotates the motor clockwise / counter clockwise direction
-- TODO: add a signal to activate (start/stop) the motor (rst)
entity unipolar_stepper is 
    generic (
        wait_count : natural := 2  -- -- wait time for the stepper        
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        cw  : in std_logic; -- counter clock wise rotation
        coils : out std_logic_vector(3 downto 0) -- connected to IN1..IN4
    );
end unipolar_stepper;

architecture rtl of unipolar_stepper is
begin

    -- Performs one of 8 micro steps
    MICROSTEP_PROC : process(clk, rst)
        variable step : std_logic_vector(0 to 2) := "111";
        variable count : natural range 0 to wait_count;
    begin
        if rst = '1' then
            coils <= "0000";
            -- we start with a step
            count := wait_count;
    
        elsif rising_edge(clk) then

            if (count < wait_count) then
                -- wait for the next micro step
                count := count + 1;
            else
                -- perfom a single micro step
                count := 0;

                if (cw = '1') then
                    step := step + 1;
                else
                    step := step - 1;
                end if;

                case step is
                    when "000" => coils <= "0001";
                    when "001" => coils <= "0011";
                    when "010" => coils <= "0010";
                    when "011" => coils <= "0110";
                    when "100" => coils <= "0100";
                    when "101" => coils <= "1100";
                    when "110" => coils <= "1000";
                    when "111" => coils <= "1001";
                    when others => coils <= "0000";
                end case;
            end if;
        end if;
    end process;

end architecture;
