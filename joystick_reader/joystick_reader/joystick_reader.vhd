library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity joystick_reader is
  generic (
    -- Defaults for the Lattice iCEstick board
    clk_hz : integer := 12e6;
    i2c_hz : integer := 100e3;
    target_addr : std_logic_vector(6 downto 0) := "1001000"
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    -- I2C
    scl : out std_logic;
    sda : inout std_logic;
    -- The ADS111x configuration
    x_config : in std_logic_vector(15 downto 0);
    y_config : in std_logic_vector(15 downto 0);
    -- AXI style
    ready : in std_logic;
    valid : out std_logic;
    x_data: out std_logic_vector(15 downto 0);
    y_data: out std_logic_vector(15 downto 0)
  );
end joystick_reader;

architecture rtl of joystick_reader is

  -- I2C Command/write bus
  signal write_tdata : std_logic_vector(7 downto 0) := (others => '0');
  signal write_tvalid : std_logic;
  signal write_tready : std_logic := '0';
  -- I2C Command/read bus
  signal read_tdata : std_logic_vector(7 downto 0) := (others => '0');
  signal read_tvalid : std_logic := '0';
  signal read_tready : std_logic;

  -- SINGLE signal mapping
  signal config : std_logic_vector(15 downto 0);
  signal output_tvalid : std_logic := '0';
  signal output_tready : std_logic;
  signal value : std_logic_vector(15 downto 0) := (others => '0');

  -- I2C signal mapping
  signal cmd_tready : std_logic := '0';
  signal rd_tready : std_logic := '0';

  signal single_shot :  std_logic := '0';
  signal y_ready : std_logic := '0';

  -- states for processing
  type state_type is (IDLE_X, PROCESSING_X, IDLE_Y, PROCESSING_Y);
  signal state : state_type := IDLE_X;

begin

  -- ADS1115 target reading a single value
  SINGLE : entity work.ads1115_single(rtl)
  port map (
    clk => clk,
    rst => rst,
    -- Command/write bus
    write_tdata => write_tdata,
    write_tvalid => write_tvalid,
    write_tready => write_tready,
    -- Command/read bus
    read_tdata => read_tdata,
    read_tvalid => read_tvalid,
    read_tready => read_tready,
    -- configuation
    config => config,
    -- value read
    ready => output_tready,
    valid => output_tvalid,
    value	=> value
  );

  -- generic I2C controller to read values from the ADS1115
  I2C_CONTROLLER : entity work.i2c_controller(rtl)
  generic map (
    clk_hz => clk_hz,
    i2c_hz => i2c_hz
    )
  port map (
    clk => clk,
    rst => rst,
    scl => scl,
    sda => sda,
    -- Command/Write bus
    cmd_tdata => write_tdata,
    cmd_tvalid => write_tvalid,
    cmd_tready => cmd_tready,
    -- Read bus
    rd_tdata => read_tdata,
    rd_tvalid => read_tvalid,
    rd_tready => rd_tready,

    nack => open
  );

  FSM_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE_X;
        single_shot <= '0';
        y_ready <= '0';
      else

        write_tready <= cmd_tready; 
        rd_tready <= read_tready;
    
        valid <= '0';

        case state is

          when IDLE_X =>

            if ready = '0' then
              single_shot <= '1';
              write_tready <= '0'; -- stop the I2C communication
              output_tready <= '0'; -- stop the SINGLE ready
            end if;

            if ready = '1' and single_shot = '1' then
              write_tready <= '1'; -- start the I2C communication
              output_tready <= '1'; -- start the SINGLE ready
              config <= x_config;
              state <= PROCESSING_X;
            end if;
        
          when PROCESSING_X =>

            single_shot <= '0';

            if output_tready = '1'and output_tvalid = '1' then
              -- report "PROCESSING_X done.";
              x_data <= value;
              -- x_data <= x"A0B1";
              -- config <= y_config;
              y_ready <= '0';
              state <= IDLE_Y;
            end if;

          when IDLE_Y =>

            if y_ready = '0' then
              single_shot <= '1';
              write_tready <= '0'; -- stop the I2C communication
              output_tready <= '0'; -- stop the SINGLE ready
              y_ready <= '1';         -- Restart
              config <= y_config;
            end if;

            if y_ready = '1' and single_shot = '1' then
              write_tready <= '1'; -- start the I2C communication
              output_tready <= '1'; -- start the SINGLE ready
              config <= y_config;
              state <= PROCESSING_Y;
            end if;
        
          when PROCESSING_Y =>

            single_shot <= '0';

            if output_tready = '1'and output_tvalid = '1' then
              -- report "PROCESSING_Y done.";
              y_data <= value;
              -- y_data <= x"C2D3";
              valid <= '1';
              state <= IDLE_X;
            end if;

        end case;
  
      end if;
    end if;
  end process;
  
end architecture;
