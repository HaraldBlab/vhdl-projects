library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    -- 21 bit counter wraps 5.7 times/second at 12 MHz
    clk_counter_bits : integer := 21;

    -- Defaults for the Lattice iCEstick board
    clk_hz : integer := 12e6;
    i2c_hz : integer := 10e3;
    baud_rate : integer := 115200
  );
  port (
    clk : in std_logic;
    rst_ext : in std_logic;
    -- UART
    uart_tx : out std_logic;
    -- I2C
    scl : out std_logic;
    sda : inout std_logic
  );
end top;

architecture rtl of top is

  signal rst : std_logic;

  -- ADS1115 reader signals
  signal ready : std_logic;
  signal valid : std_logic;
  signal data : std_logic_vector(15 downto 0);

  -- UART module signals
  signal send_tdata : std_logic_vector(7 downto 0);
  signal send_tvalid : std_logic;
  signal send_tready : std_logic;

  -- This counter controls how often samples are fetched and sent
  signal clk_counter : unsigned(clk_counter_bits - 1 downto 0);

  -- ADS1115 configuration register
  -- configuration MSB predefines
  constant OS_SINGLE : std_logic := '1';
  constant MUX_AIN0_GND : std_logic_vector(2 downto 0) := "100";
  constant PGA_FSR_6144 : std_logic_vector(2 downto 0) := "000";
  constant PGA_FSR_2048 : std_logic_vector(2 downto 0) := "010";
  constant MODE_SINGLE : std_logic := '1';
  constant MODE_CONTINOUS : std_logic := '0';
  ---
  constant config_msb : std_logic_vector(7 downto 0) := 
    OS_SINGLE & MUX_AIN0_GND & 
    PGA_FSR_6144 & MODE_CONTINOUS;
  
  -- configuration LSB predefines
  constant DR_SPS_128 : std_logic_vector(2 downto 0) := "100";
  constant COMP_MODE_TRADITIONAL : std_logic := '0';
  constant COMP_POL_LOW : std_logic := '0';
  constant COMP_LAT_NONLATCHING : std_logic := '0';
  constant COMP_QUE_DISABLE : std_logic_vector(1 downto 0) := "11";
  ---
  constant config_lsb : std_logic_vector(7 downto 0) := 
    DR_SPS_128 & COMP_MODE_TRADITIONAL & 
    COMP_POL_LOW & COMP_LAT_NONLATCHING & COMP_QUE_DISABLE;
  -- configuration used
  constant config : std_logic_vector(15 downto 0) := config_msb & config_lsb;
  
  -- data recevied from the READER
  signal output_data : std_logic_vector(15 downto 0);

  type state_type is (WAITING, GETTING, SENDING_MSB, SENDING_LSB);
  signal state : state_type;

begin

  -- synchonized reset
  RESET_SYNC : entity work.reset_sync(rtl)
    port map (
      clk => clk,
      rst_in => rst_ext,
      rst_out => rst
    );

  -- sensor to read (single) value (two's compliment)
  ADS115_READER : entity work.ads1115_reader(rtl)
    generic map (
      clk_hz => clk_hz
    )
    port map (
      clk => clk,
      rst => rst,
      -- I2C
      scl => scl,
      sda => sda,
      -- configuration
      config => config,
      -- AXI style
      ready => ready,
      valid => valid,
      data => data
    );

  -- UART to publish read value
  UART : entity work.uart_tx(rtl)
    generic map (
      clk_hz => clk_hz,
      baud_rate => baud_rate
    )
    port map (
      clk => clk,
      rst => rst,
      send_tdata => send_tdata,
      send_tvalid => send_tvalid,
      send_tready => send_tready,
      tx => uart_tx
    );

    FSM_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          clk_counter <= (others => '0');
          state <= WAITING;
          ready <= '0';
          send_tdata <= (others => '0');
          send_tvalid <= '0';

        else
          clk_counter <= clk_counter + 1;
        
          case state is
            
            -- Wait for some time
            when WAITING =>

              -- If every bit in clk_counter is a '1'
              if signed(clk_counter) = to_signed(-1, clk_counter'length) then
                state <= GETTING;
                ready <= '1';
              end if;

            -- Fetch the results from the ADS1115 sensor
            when GETTING =>
                
              if valid = '1' then
                state <= SENDING_MSB;
                output_data <= data;
                -- prepare to send the MSB 
                send_tdata <= data(15 downto 8);
                send_tvalid <= '1';
                ready <= '0';
              end if;
            
            -- Wait until the UART module acknowledges the transfer
            when SENDING_MSB =>

              -- prepare to send the MSB 
              -- send_tdata <= output_data(15 downto 8);
              send_tvalid <= '1';

              -- If done or if the sending timed out
              if send_tready = '1' then
                -- report "Sent MSB";
                state <= SENDING_LSB;
                send_tvalid <= '0';
                send_tdata <= data(7 downto 0);
                send_tvalid <= '1';
                end if;

            -- Wait until the UART module acknowledges the transfer
            when SENDING_LSB =>

              -- prepare to send the LSB 
              -- send_tdata <= output_data(7 downto 0);
              send_tvalid <= '1';

            -- If done or if the sending timed out
            if send_tready = '1' then
              -- report "Sent LSB";
              state <= WAITING;
              send_tvalid <= '0';
            end if;

          end case;
          
        end if;
      end if;
    end process;

end architecture;
