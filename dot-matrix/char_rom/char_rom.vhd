library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
library dot_matrix;
use dot_matrix.types.all;
use dot_matrix.charmap.all;
 
entity char_rom is
  port (
    clk : in std_logic;
    addr : in char_range;
    dout : out matrix_type
  );
end char_rom; 
 
architecture rtl of char_rom is
 
  -- The ROM containing our character map
  constant rom : charmap_type := charmap;
 
begin
 
  PROC_ROM : process(clk)
  begin
    if rising_edge(clk) then
      dout <= rom(addr);
    end if;

  end process; -- PROC_ROM
 
end architecture;
