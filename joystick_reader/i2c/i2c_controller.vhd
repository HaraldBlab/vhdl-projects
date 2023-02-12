library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.round;

entity i2c_controller is
  generic (
    clk_hz : integer := 100e6;
    i2c_hz : integer := 100e3
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    
    scl : out std_logic := 'Z';
    sda : inout std_logic := 'Z';

    -- Command/write bus
    cmd_tdata : in std_logic_vector(7 downto 0);
    cmd_tvalid : in std_logic;
    cmd_tready : out std_logic;

    -- Read bus
    rd_tdata : out std_logic_vector(7 downto 0);
    rd_tvalid : out std_logic;
    rd_tready : in std_logic;

    -- Not acknowledge (pulsed on every received NACK)
    nack : out std_logic
  );
end i2c_controller;

architecture rtl of i2c_controller is

  constant CMD_BUS_RST : std_logic_vector(7 downto 0)         := x"00";
  constant CMD_START_CONDITION : std_logic_vector(7 downto 0) := x"01";
  constant CMD_TX_BYTE : std_logic_vector(7 downto 0)         := x"02";
  constant CMD_RX_BYTE_ACK : std_logic_vector(7 downto 0)     := x"03";
  constant CMD_RX_BYTE_NACK : std_logic_vector(7 downto 0)    := x"04";
  constant CMD_STOP_CONDITION : std_logic_vector(7 downto 0)  := x"05";

  type state_type is (RST_SEQ, WAIT_COMMAND, START_CONDITON,
    STOP_CONDITION, WAIT_TX_BYTE, TX_BYTE, RX_BYTE, RETURN_RX_BYTE);
  signal state : state_type;

  signal scl_i : std_logic := '1';
  signal sda_i : std_logic := '1';

  -- Clock cycles per half period of SCL rounded to nearest int
  constant cycles_per_half_scl : integer :=
    integer(round(real(clk_hz) / real(i2c_hz)) / 2.0);

  -- Clock cycle counter
  constant clk_cnt_max : integer := cycles_per_half_scl - 1;
  signal clk_cnt : integer range 0 to clk_cnt_max;

  -- SCL half period counter
  constant scl_hp_cnt_max : integer := 31;
  signal scl_hp_cnt : integer range 0 to scl_hp_cnt_max;

  signal rx_ack_bit_to_send : std_logic;
  signal byte_to_send : std_logic_vector(7 downto 0);
  signal sample_ack : std_logic;

  -- How many nanoseconds to delay SDA out with respect to SCL
  constant sda_delay_ns : integer := 400;

  -- Shift reg for delaying SDA
  constant sda_delay_cycles : integer 
    := integer(real(sda_delay_ns) / ((1.0 / real(clk_hz)) * 1.0e9));
  signal sda_delay : std_logic_vector(sda_delay_cycles - 2 downto 0) := (others => '1');

  signal sda_sampled : std_logic_vector(7 downto 0);

begin

  SCL_OUT_PROC : process(scl_i)
  begin
    if scl_i = '0' then
      scl <= '0';
    else
      scl <= 'Z';
    end if;
  end process;

  SDA_OUT_PROC : process(clk)
  begin
    if rising_edge(clk) then
    
      if rst = '1' then
        sda_delay <= (others => '1');

      else

        sda_delay <= sda_i & sda_delay(sda_delay'high downto 1);

        if sda_delay(0) = '0' then
          sda <= '0';
        else
          sda <= 'Z';
        end if;

      end if;
    end if;
  end process;

  FSM_PROC : process(clk)

    procedure change_state(next_state : state_type) is
    begin
      state <= next_state;
      clk_cnt <= 0;
      scl_hp_cnt <= 0;
    end procedure;

    impure function scl_half_period(count : integer) return boolean is
    begin
      if clk_cnt = clk_cnt_max then
        clk_cnt <= 0;
        scl_i <= not scl_i;

        -- If we should check the target's ACK on the next falling SCL
        if sample_ack = '1' and scl_i = '1' then
          sample_ack <= '0';

          if sda = '0' then
            nack <= '0';
          else
            nack <= '1';
          end if;
        end if;

        if scl_hp_cnt = scl_hp_cnt_max then
          scl_hp_cnt <= 0;
        else
          scl_hp_cnt <= scl_hp_cnt + 1;
        end if;

        return scl_hp_cnt = count;
      else
        clk_cnt <= clk_cnt + 1;
        return false;
      end if;
    end function;

    impure function read_sda return std_logic is
    begin
      if sda = '0' then
        return '0';
      else
        return '1';
      end if;
    end function;

  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= RST_SEQ;
        cmd_tready <= '0';
        rd_tdata <= (others => '0');
        rd_tvalid <= '0';
        nack <= '0';
        scl_i <= '1';
        sda_i <= '1';
        clk_cnt <= 0;
        scl_hp_cnt <= 0;
        rx_ack_bit_to_send <= '0';
        byte_to_send <= (others => '0');
        sample_ack <= '0';
        sda_sampled <= (others => '0');
  
      else

        -- Pulsed
        nack <= '0';

        case state is
  
          when RST_SEQ =>

            sda_i <= '1';

            if scl_half_period(31) then
              change_state(WAIT_COMMAND);
            end if;

          when WAIT_COMMAND =>

            cmd_tready <= '1';

            if cmd_tvalid = '1' and cmd_tready = '1' then
              cmd_tready <= '0';

              case cmd_tdata is

                when CMD_START_CONDITION =>
                  change_state(START_CONDITON);

                when CMD_TX_BYTE =>
                  change_state(WAIT_TX_BYTE);

                when CMD_RX_BYTE_ACK =>
                  change_state(RX_BYTE);
                  rx_ack_bit_to_send <= '0';

                when CMD_RX_BYTE_NACK =>
                  change_state(RX_BYTE);
                  rx_ack_bit_to_send <= '1';

                when CMD_STOP_CONDITION =>
                  change_state(STOP_CONDITION);

                when others => -- CMD_BUS_RST
                  change_state(RST_SEQ);
              
              end case;

            end if;
            
          when START_CONDITON =>

            if scl_half_period(0) then
              change_state(WAIT_COMMAND);
              sda_i <= '0';
            end if;

            scl_i <= '1';
          
          when STOP_CONDITION =>

            if scl_half_period(0) then
              sda_i <= '0';
            end if;

            if scl_half_period(2) then
              change_state(WAIT_COMMAND);
              sda_i <= '1';
              scl_i <= '1';
            end if;
          
          when WAIT_TX_BYTE =>

            cmd_tready <= '1';

            if cmd_tvalid = '1' and cmd_tready = '1' then
              change_state(TX_BYTE);
              cmd_tready <= '0';
              byte_to_send <= cmd_tdata;
            end if;
            
          when TX_BYTE =>

            for i in 0 to 7 loop
              if scl_half_period(2 * i) then
                sda_i <= byte_to_send(7);
                byte_to_send <= byte_to_send(6 downto 0) & '0';
              end if;
            end loop;
            
            if scl_half_period(16) then
              sda_i <= '1';
            end if;

            if scl_half_period(17) then
              change_state(WAIT_COMMAND);
              sample_ack <= '1';
            end if;
          
          when RX_BYTE =>

            if scl_half_period(0) then
              sda_i <= '1';
            end if;

            for i in 1 to 8 loop
              if scl_half_period(2 * i) then
                sda_sampled <= sda_sampled(6 downto 0) & read_sda;
              end if;
            end loop;

            if scl_half_period(16) then
              -- Send Ack or Nack
              sda_i <= rx_ack_bit_to_send;
            end if;

            if scl_half_period(17) then
              change_state(RETURN_RX_BYTE);
            end if;
            
          when RETURN_RX_BYTE =>

            rd_tdata <= sda_sampled;
            rd_tvalid <= '1';

            if rd_tvalid = '1' and rd_tready = '1' then
              change_state(WAIT_COMMAND);
              rd_tvalid <= '0';
            end if;
            
  
        end case;
  
      end if;
    end if;
  end process;

end architecture;