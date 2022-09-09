library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        rst_n : in std_logic; -- Pullup
        coils : out std_logic_vector(3 downto 0) -- connected to IN1..IN4
    );
end top;

architecture rtl of top is
    -- TODO: Lattice ICE40 specific (constant_pck)
    constant clk_hz : integer := 12e6;

    -- current direction
    constant cw: std_logic := '1';
    -- current speed (slowlyness)
    constant wait_count : natural := 24000;  -- 2 ms  wait time for the stepper        

    -- Internal reset
    signal rst : std_logic;

begin

    RESET : entity work.reset(rtl)
    port map (
      clk => clk,
      rst_n => rst_n,
      rst => rst
    );
  
    STEPPER : entity work.unipolar_stepper(rtl)
    generic map (
        wait_count => wait_count
    )
    port map (
        clk => clk,
        rst => rst,
        cw => cw,
        coils => coils
    );

end architecture;