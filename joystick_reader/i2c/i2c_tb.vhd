library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

entity i2c_tb is
end i2c_tb;

architecture sim of i2c_tb is

  procedure print(msg : string) is
    variable l : line;
  begin
    write(l, to_string(now) & " - " & msg);
    writeline(output, l);
  end procedure;

  constant clk_hz : integer := 10e6;
  constant clk_period : time := 1 sec / clk_hz;

  constant i2c_hz : integer := 100e3;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal scl : std_logic;
  signal sda : std_logic;
  signal cmd_tdata : std_logic_vector(7 downto 0) := (others => '0');
  signal cmd_tvalid : std_logic := '0';
  signal cmd_tready : std_logic;
  signal rd_tdata : std_logic_vector(7 downto 0);
  signal rd_tvalid : std_logic;
  signal rd_tready : std_logic := '0';
  signal nack : std_logic;

begin

  clk <= not clk after clk_period / 2;

  -- Pullup
  scl <= 'H';
  sda <= 'H';

  DUT : entity work.i2c_controller(bfm)
  generic map (
    clk_hz => clk_hz,
    i2c_hz => i2c_hz
  )
  port map (
    clk => clk,
    rst => rst,
    scl => scl,
    sda => sda,
    cmd_tdata => cmd_tdata,
    cmd_tvalid => cmd_tvalid,
    cmd_tready => cmd_tready,
    rd_tdata => rd_tdata,
    rd_tvalid => rd_tvalid,
    rd_tready => rd_tready,
    nack => nack
  );
  
  DETECT_START_PROC : process
  begin
    wait until scl = 'H' and falling_edge(sda);
    print("Detected start condition");
  end process;

  DETECT_STOP_PROC : process
  begin
    wait until scl = 'H' and rising_edge(sda);
    print("Detected stop condition");
  end process;

  SEQUENCER_PROC : process

    procedure send_cmd(cmd : std_logic_vector(7 downto 0)) is
    begin
      print("send_cmd: " & to_string(cmd));
  
      cmd_tdata <= cmd;
      cmd_tvalid <= '1';
      
      loop
        wait until rising_edge(clk);
        if cmd_tvalid = '1' and cmd_tready = '1' then
          cmd_tvalid <= '0';
          exit;
        end if;
      end loop;
    end procedure;

    procedure read_byte is
      begin
        rd_tready <= '1';
        
        loop
          wait until rising_edge(clk);
          if rd_tvalid = '1' and rd_tready = '1' then
            print("Received byte from DUT: " & to_string(rd_tdata));
            rd_tready <= '0';
            exit;
          end if;
        end loop;
      end procedure;

  begin
    wait for clk_period * 2;

    rst <= '0';

    send_cmd(x"00"); -- CMD_BUS_RST
    send_cmd(x"01"); -- CMD_START_CONDITION

    send_cmd(x"02"); -- CMD_TX_BYTE
    send_cmd(x"AA"); -- Byte to send

    send_cmd(x"05"); -- CMD_STOP_CONDITION


    send_cmd(x"01"); -- CMD_START_CONDITION

    send_cmd(x"03"); -- CMD_RX_BYTE_ACK
    read_byte;
    send_cmd(x"04"); -- CMD_RX_BYTE_NACK
    read_byte;

    send_cmd(x"05"); -- CMD_STOP_CONDITION

    wait for clk_period * 2000;

    finish;
  end process;

end architecture;