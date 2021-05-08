library ieee;
use ieee.std_logic_1164.all;
 
use std.textio.all;
 
library dot_matrix;
use dot_matrix.types.all;

library dot_matrix_sim;
use dot_matrix_sim.sim_constants.all;
 
package sim_subprograms is
 
  -- Generate the clock signal
  procedure gen_clock(signal clk : inout std_logic);
 
  -- Print message with test OK
  procedure print_test_ok;

  -- Print a multiline representation of the matrix_type
  procedure print_char(constant char : matrix_type);
   
end package;
 
package body sim_subprograms is
 
  procedure gen_clock(signal clk : inout std_logic) is
  begin
    clk <= not clk after clock_period / 2;
  end procedure;
 
  procedure print_test_ok is
    variable str : line;
  begin
    write(str, string'("Test: OK"));
    writeline(output, str);
  end procedure;

  procedure print_char(constant char : matrix_type) is
    variable str : line;
  begin
    for row in char'range loop
      for col in char(row)'range loop
        if char(row)(col) = '1' then
          write(str, string'("X"));
        else
          write(str, string'("."));
        end if;
      end loop;
      writeline(output, str);
    end loop;
  end procedure;
 
end package body;
