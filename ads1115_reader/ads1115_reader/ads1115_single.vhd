library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- start a single conversion
entity ads1115_single is
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
    
    -- The ADS111x provide 16 bits of data in binary two's complement format
    ready : in std_logic;
    valid : out std_logic;
    value : out std_logic_vector(15 downto 0)
    );
end ads1115_single;

architecture rtl of ads1115_single is

  constant write_addr : std_logic_vector(7 downto 0) := x"90";
  constant read_addr : std_logic_vector(7 downto 0) := x"91";
  -- configuration register (to define the value we want to read)
  constant config_reg : std_logic_vector(7 downto 0) := x"01";
  constant config_lsb : std_logic_vector(7 downto 0) := x"C4";
  constant config_msb : std_logic_vector(7 downto 0) := x"83";
  -- conversion register (to read values from)
  constant conversion_reg : std_logic_vector(7 downto 0) := x"00";

  type state_type is (IDLE, WRITE, READ);
  signal state : state_type := IDLE; 

  constant bytes_to_send : integer := 10+12-1;
  signal write_count : integer range 0 to bytes_to_send;
  -- TODO: this could be a boolean value
  constant bytes_to_read : integer := 2-1;
  signal read_count : integer range 0 to bytes_to_read;

  -- indicates if the write sequence has been to be executed after a ready
  signal single_shot :  std_logic := '0';
  -- indicates that we need to read a byte after the write has completed
  signal read_next : std_logic := '0';

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
            state <= WRITE;
          end if;
          
        when WRITE =>
          
          write_tvalid <= '1';
          read_next <= '0';
          single_shot <= '0';

          -- write data to controller
          case write_count is
          
            -- write configuration
            when 0 => write_tdata <= x"01"; -- state = WAIT_START;
            when 1 => write_tdata <= x"02";
            when 2 => write_tdata <= write_addr;
            when 3 => write_tdata <= x"02";
            when 4 => write_tdata <= config_reg;
            when 5 => write_tdata <= x"02";
            when 6 => write_tdata <= config_lsb;
            when 7 => write_tdata <= x"02";
            when 8 => write_tdata <= config_msb;
            when 9 => write_tdata <= x"05"; -- state <= WAIT_STOP;
            -- write to address register
            when 10 => write_tdata <= x"01";
            when 11 => write_tdata <= x"02";
            when 12 => write_tdata <= write_addr;
            when 13 => write_tdata <= x"02";
            when 14 => write_tdata <= conversion_reg;
            when 15 => write_tdata <= x"05";
            -- read from conversion register
            when 16 => write_tdata <= x"01";
            when 17 => write_tdata <= x"02";
            when 18 => write_tdata <= read_addr;
            when 19 => write_tdata <= x"03"; read_next <= '1';
            when 20 => write_tdata <= x"04"; read_next <= '1';
            -- the last one
            when others => write_tdata <= x"05";
      
          end case;

          if write_tvalid = '1' and write_tready = '1' then
            write_tvalid <= '0';
            if (write_count < bytes_to_send) then
              write_count <= write_count + 1;
              if (read_next = '1') then
                state <= READ;
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
        
        when READ =>

          read_tready <= '1';

          if read_tvalid = '1' and read_tready = '1' then
            -- report "State: READ with ready: " & to_string(read_tready) & " valid: " & to_string(read_tvalid);
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
            -- value <= x"ABCD";

            state <= WRITE;

          end if;

      end case;

    end if;
  end if;
end process;

end architecture;