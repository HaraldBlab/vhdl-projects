library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- start a single conversion
entity ads1115_single is
  generic(
    target_addr : std_logic_vector(6 downto 0) := "1001000"
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Command/write bus
    write_tdata : out std_logic_vector(7 downto 0);
    write_tvalid : inout std_logic; -- out only in 2008
    write_tready : in std_logic;

    -- read bus
    read_tdata : in std_logic_vector(7 downto 0);
    read_tvalid : in std_logic;
    read_tready : inout std_logic;   -- out only in 2008
    
    -- The ADS111x configuration
    config : in std_logic_vector(15 downto 0);

    -- The ADS111x provide 16 bits of data in binary two's complement format
    ready : in std_logic;
    valid : out std_logic;
    value : out std_logic_vector(15 downto 0)
    );
end ads1115_single;

architecture rtl of ads1115_single is

  constant write_addr : std_logic_vector(7 downto 0) := target_addr & '0';
  constant read_addr : std_logic_vector(7 downto 0) := target_addr & '1';
  -- configuration register (to define the value we want to read)
  constant config_reg : std_logic_vector(7 downto 0) := x"01";
  -- conversion register (to read values from)
  constant conversion_reg : std_logic_vector(7 downto 0) := x"00";
  
  -- values written to the configuration register
  signal config_lsb : std_logic_vector(7 downto 0) := x"00";
  signal config_msb : std_logic_vector(7 downto 0) := x"00";
  -- value read from the configuration register
  signal config_value : std_logic_vector(15 downto 0);

  type state_type is (IDLE, WRITE, READ_CONFIG, CHECK_CONFIG, READ_VALUE);
  signal state : state_type := IDLE; 

  constant bytes_to_send : integer := 55;
  signal write_count : integer range 0 to bytes_to_send;
  -- where the read configuration starts in the write buffer
  constant write_readconfig : integer := 30;
  -- where the read value starts in the write buffer
  constant write_readvalue : integer := 42;

  -- TODO: this could be a boolean for read(msb) or read(lsb)
  constant bytes_to_read : integer := 2-1;
  signal read_count : integer range 0 to bytes_to_read;

  -- indicates if the write sequence has been to be executed after a ready
  signal single_shot :  std_logic := '0';
  -- indicates that we need to read a byte after the write has completed
  signal next_read_value : std_logic := '0';
  -- indicates that we need to read the status
  signal next_read_config : std_logic := '0';
  -- indicates that we need to check the status
  signal next_check_config : std_logic := '0';

begin

FSM_PROC : process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      state <= IDLE;
      valid <= '0';
      write_count <= 0;
      value <= (others => 'X');
      single_shot <= '0';

    else
      write_tvalid <= '0';
      -- pulsed
      valid <= '0';

      case state is

        when IDLE =>
          
          write_count <= 0;
          if ready = '0' then
            single_shot <= '1';
          end if;

          if (ready = '1' and single_shot = '1') then
            config_msb <= config(15 downto 8);
            config_lsb <= config(7 downto 0);
            state <= WRITE;
          end if;
          
        when WRITE =>
          
          write_tvalid <= '1';
          next_read_config <= '0';
          next_read_value <= '0';
          next_check_config <= '0';
          single_shot <= '0';

          -- write data to controller
          case write_count is
          
            -- define ADC to use
            when 0 => write_tdata <= x"01"; -- state = WAIT_START;
            when 1 => write_tdata <= x"02";
            when 2 => write_tdata <= write_addr;
            when 3 => write_tdata <= x"02";
            when 4 => write_tdata <= config_reg;  -- write configuration (continuous)
            when 5 => write_tdata <= x"02";
            when 6 => write_tdata <= config_msb;
            when 7 => write_tdata <= x"02";
            when 8 => write_tdata <= config_lsb;
            when 9 => write_tdata <= x"05"; -- state <= WAIT_STOP;
            -- Set mode (set single mode)
            when 10 => write_tdata <= x"01"; -- state = WAIT_START;
            when 11 => write_tdata <= x"02";
            when 12 => write_tdata <= write_addr;
            when 13 => write_tdata <= x"02";
            when 14 => write_tdata <= config_reg;
            when 15 => write_tdata <= x"02";
            when 16 => write_tdata <= config_msb or x"01";  -- set MODE_SINGLE
            when 17 => write_tdata <= x"02";
            when 18 => write_tdata <= config_lsb;
            when 19 => write_tdata <= x"05"; -- state <= WAIT_STOP;
            -- Start single mode
            when 20 => write_tdata <= x"01"; -- state = WAIT_START;
            when 21 => write_tdata <= x"02";
            when 22 => write_tdata <= write_addr;
            when 23 => write_tdata <= x"02";
            when 24 => write_tdata <= config_reg;
            when 25 => write_tdata <= x"02";
            when 26 => write_tdata <= config_msb or x"81";  -- set OS_SINGLE
            when 27 => write_tdata <= x"02";
            when 28 => write_tdata <= config_lsb;
            when 29 => write_tdata <= x"05"; -- state <= WAIT_STOP;
            -- repeat: wait conversion done
            when 30 => write_tdata <= x"01";
            when 31 => write_tdata <= x"02";
            when 32 => write_tdata <= write_addr;
            when 33 => write_tdata <= x"02";
            when 34 => write_tdata <= config_reg;
            when 35 => write_tdata <= x"05";
            -- read from config register
            when 36 => write_tdata <= x"01";
            when 37 => write_tdata <= x"02";
            when 38 => write_tdata <= read_addr;
            when 39 => write_tdata <= x"03"; next_read_config <= '1';
            when 40 => write_tdata <= x"04"; next_read_config <= '1';
            when 41 => write_tdata <= x"05"; next_check_config <= '1';
            -- write to address register
            when 42 => write_tdata <= x"01";
            when 43 => write_tdata <= x"02";
            when 44 => write_tdata <= write_addr;
            when 45 => write_tdata <= x"02";
            when 46 => write_tdata <= conversion_reg;
            when 47 => write_tdata <= x"05";
            -- read from conversion register
            when 48 => write_tdata <= x"01";
            when 49 => write_tdata <= x"02";
            when 50 => write_tdata <= read_addr;
            when 51 => write_tdata <= x"03"; next_read_value <= '1';
            when 52 => write_tdata <= x"04"; next_read_value <= '1';
            when 53 => write_tdata <= x"05";
            -- the last one
            when others => write_tdata <= x"05";
      
          end case;

          if write_tvalid = '1' and write_tready = '1' then
            write_tvalid <= '0';
            if (write_count < bytes_to_send) then
              write_count <= write_count + 1;
              if (next_read_value = '1') then
                read_tready <= '1';
                state <= READ_VALUE;
              elsif (next_read_config = '1') then
                read_tready <= '1';
                state <= READ_CONFIG;
              elsif (next_check_config = '1') then
                state <= CHECK_CONFIG;
              end if;
              -- else state <= WRITE;
            else
              -- report "Write done.";
              write_count <= 0;
              state <= IDLE;
              valid <= '1';
              -- turn off sending if still ready
            end if;
          end if;

        when READ_CONFIG =>

          read_tready <= '1';

          if read_tvalid = '1' and read_tready = '1' then
            -- report "READ_CONFIG ";
            read_tready <= '0';
            if read_count < bytes_to_read then
              read_count <= read_count + 1;
            else
              read_count <= 0;
            end if;

            -- we read MSB first, LSB second
            if (read_count = 0) then
              config_value(15  downto 8) <= read_tdata;
            else
              config_value(7 downto 0) <= read_tdata;
            end if;

            read_tready <= '0';
            state <= WRITE;

          end if;

        when CHECK_CONFIG =>

          -- report "CHECK_CONFIG ";

          if config_value(config_value'high) = '1' then
            write_count <= write_readvalue;
          else
            write_count <= write_readconfig;
          end if;

          state <= WRITE;
              
        when READ_VALUE =>

          read_tready <= '1';

          if read_tvalid = '1' and read_tready = '1' then
            -- report "READ_VALUE ";
            read_tready <= '0';
            if read_count < bytes_to_read then
              read_count <= read_count + 1;
            else
              read_count <= 0;
            end if;

            -- we read MSB first, LSB second
            if (read_count = 0) then
              value(15  downto 8) <= read_tdata;
            else
              value(7 downto 0) <= read_tdata;
            end if;
            -- value <= config;

            read_tready <= '0';
            state <= WRITE;

          end if;

      end case;

    end if;
  end if;
end process;

end architecture;