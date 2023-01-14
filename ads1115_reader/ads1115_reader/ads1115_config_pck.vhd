library ieee;
use ieee.std_logic_1164.all;

package ads1115_config is

  -- ads115.pdf p23
  -- I2C Address Selection
  constant ADDR_GND : std_logic_vector(6 downto 0) := "1001000";
  constant ADDR_VDD : std_logic_vector(6 downto 0) := "1001001";
  constant ADDR_SDA : std_logic_vector(6 downto 0) := "1001010";
  constant ADDR_SCL : std_logic_vector(6 downto 0) := "1001011";

  -- ads1115.pdf p28
  -- configuration MSB predefines
  constant OS_SINGLE : std_logic := '1';
  -- Input multiplexer configuration
  -- These bits configure the input multiplexer. 
  constant MUX_AIN0_GND : std_logic_vector(2 downto 0) := "100";
  constant MUX_AIN1_GND : std_logic_vector(2 downto 0) := "101";
  constant MUX_AIN2_GND : std_logic_vector(2 downto 0) := "110";
  constant MUX_AIN3_GND : std_logic_vector(2 downto 0) := "111";
  --
  constant PGA_FSR_6144 : std_logic_vector(2 downto 0) := "000";
  constant PGA_FSR_2048 : std_logic_vector(2 downto 0) := "010";
  constant MODE_SINGLE : std_logic := '1';
  constant MODE_CONTINOUS : std_logic := '0';
  
  -- configuration LSB predefines
  constant DR_SPS_128 : std_logic_vector(2 downto 0) := "100";
  constant COMP_MODE_TRADITIONAL : std_logic := '0';
  constant COMP_POL_LOW : std_logic := '0';
  constant COMP_LAT_NONLATCHING : std_logic := '0';
  constant COMP_QUE_DISABLE : std_logic_vector(1 downto 0) := "11";

  -- used configurations
  constant config_A0_5V : std_logic_vector(15 downto 0) :=
    OS_SINGLE & MUX_AIN0_GND & PGA_FSR_6144 & MODE_CONTINOUS &
    DR_SPS_128 & COMP_MODE_TRADITIONAL & COMP_POL_LOW & COMP_LAT_NONLATCHING & COMP_QUE_DISABLE;

  constant config_A1_5V : std_logic_vector(15 downto 0) :=
    OS_SINGLE & MUX_AIN1_GND & PGA_FSR_6144 & MODE_CONTINOUS &
    DR_SPS_128 & COMP_MODE_TRADITIONAL & COMP_POL_LOW & COMP_LAT_NONLATCHING & COMP_QUE_DISABLE;

  constant config_A2_5V : std_logic_vector(15 downto 0) :=
    OS_SINGLE & MUX_AIN2_GND & PGA_FSR_6144 & MODE_CONTINOUS &
    DR_SPS_128 & COMP_MODE_TRADITIONAL & COMP_POL_LOW & COMP_LAT_NONLATCHING & COMP_QUE_DISABLE;

  constant config_A3_5V : std_logic_vector(15 downto 0) :=
    OS_SINGLE & MUX_AIN3_GND & PGA_FSR_6144 & MODE_CONTINOUS &
    DR_SPS_128 & COMP_MODE_TRADITIONAL & COMP_POL_LOW & COMP_LAT_NONLATCHING & COMP_QUE_DISABLE;


end package;

package body ads1115_config is

end package body;