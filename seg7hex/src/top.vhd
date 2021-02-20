library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    clk_hz : integer := 12e6;
    alt_counter_len : integer := 16
  );
  port (
    clk : in std_logic;
    rst_n : in std_logic;
    segments : out std_logic_vector(6 downto 0);
    digit_sel : out std_logic
  );
end top;

architecture rtl of top is

  -- Internal reset
  signal rst : std_logic;

  -- Shift register for generating the internal reset
  signal shift_reg : std_logic_vector(7 downto 0);

  -- Binary-coded heximal
  subtype digit_type is unsigned(3 downto 0);
  signal digit : digit_type;
  type digits_type is array (0 to 1) of digit_type;
  signal digits : digits_type;
  
  -- For timing the 7-seg counting
  constant tick_counter_max : integer := clk_hz / 10 - 1;
  signal tick_counter : integer range 0 to tick_counter_max;
  signal tick : std_logic;

  -- Counter for alternating between ones and sixteens on the display
  -- 12e6 MHz / (2 ** 16) = 183.1 Hz refresh rate
  signal alt_counter : unsigned(alt_counter_len - 1 downto 0);

  -- Finite-state machine (FSM)
  type hex_state_type is (COUNT_ONES, COUNT_SIXTEENS);
  signal hex_state : hex_state_type;

begin

  HEX_FSM_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        digits <= (others => "0000");
        hex_state <= COUNT_ONES;

      else
 
        if tick = '1' then
          digits(0) <= digits(0) + 1;
        end if;
 
        case hex_state is
 
          when COUNT_ONES =>
            if digits(0) = 15 then
              hex_state <= COUNT_SIXTEENS;
            end if;
 
          when COUNT_SIXTEENS =>
 
            if tick = '1' then
              digits(1) <= digits(1) + 1;

              hex_state <= COUNT_ONES;
            end if;
 
        end case;
 
      end if;
    end if;
  end process;

  ALTERNATE_COUNTER_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        alt_counter <= (others => '0');
 
      else
        alt_counter <= alt_counter + 1;
 
      end if;
    end if;
  end process;

  OUTPUT_MUX_PROC : process(alt_counter)
  begin
    if alt_counter(alt_counter'high) = '1' then
      digit <= digits(1);
      digit_sel <= '1';
    else
      digit <= digits(0);
      digit_sel <= '0';
    end if;
  end process;

  TICK_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        tick_counter <= 0;
        tick <= '0';
 
      else
 
        if tick_counter = tick_counter_max then
          tick_counter <= 0;
          tick <= '1';
        else
          tick_counter <= tick_counter + 1;
          tick <= '0';
        end if;
 
      end if;
    end if;
  end process;

  SHIFT_REG_PROC : process(clk)
  begin
    if rising_edge(clk) then
      shift_reg <= shift_reg(6 downto 0) & rst_n;
    end if;
  end process;

  RESET_PROC : process(shift_reg)
  begin
    if shift_reg = "11111111" then
      rst <= '0';
    else
      rst <= '1';
    end if;
  end process;

  ENCODER_PROC : process(digit)

  constant A : integer := 0;
  constant B : integer := 1;
  constant C : integer := 2;
  constant D : integer := 3;
  constant E : integer := 4;
  constant F : integer := 5;
  constant G : integer := 6;

  begin
    segments <= (others => '1');

    case digit is
    
      when "0000" =>
        segments(G) <= '0';

      when "0001" =>
        segments <= (others => '0');
        segments(B) <= '1';
        segments(C) <= '1';

      when "0010" =>
        segments(C) <= '0';
        segments(F) <= '0';

      when "0011" =>
        segments(E) <= '0';
        segments(F) <= '0';

      when "0100" =>
        segments(A) <= '0';
        segments(D) <= '0';
        segments(E) <= '0';

      when "0101" =>
        segments(B) <= '0';
        segments(E) <= '0';

      when "0110" =>
        segments(B) <= '0';

      when "0111" =>
        segments(D) <= '0';
        segments(E) <= '0';
        segments(F) <= '0';
        segments(G) <= '0';

      when "1000" =>
    
      when "1001" =>
        segments(E) <= '0';

      when "1010" =>
        segments(D) <= '0';
      
      when "1011" =>
        segments(A) <= '0';
        segments(B) <= '0';

      when "1100" =>
        segments(B) <= '0';
        segments(C) <= '0';
        segments(G) <= '0';
      
      when "1101" =>
        segments(A) <= '0';
        segments(F) <= '0';
      
      when "1110" =>
        segments(B) <= '0';
        segments(C) <= '0';
      
      when "1111" =>
        segments(B) <= '0';
        segments(C) <= '0';
        segments(D) <= '0';

        when others =>
        segments <= (others => '0');
  
    end case;
  end process;
end architecture;