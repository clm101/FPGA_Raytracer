library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_rx is
    generic(
        baud_rate : integer := 9600;
        byte_size : integer := 1);
    port(
        sys_clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        rx_in : in STD_LOGIC;
        rx_active : out STD_LOGIC;
        rx_done : out STD_LOGIC;
        rx_data_out : out STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0));
end UART_rx;

architecture UART_rx_arch of UART_rx is
    type rx_states_t is (IDLE, START, RX, STOP);
    signal rx_state : rx_states_t := IDLE;
    constant baud_freq_max_count : integer := (100_000_000 / baud_rate) - 1;
    constant baud_freq_x16_max_count : integer := baud_freq_max_count / 16;
    constant msg_length : integer := 8 * byte_size;
    
    signal rx_in_buf : STD_LOGIC := '0';
    signal rx_in_read : STD_LOGIC := '0';
    
    signal rx_data_out_reg : STD_LOGIC_VECTOR(msg_length - 1 downto 0) := (others => '0');
begin
    -- Buffer the input
    p_rx_buffer: process(sys_clk)
    begin
        if(rising_edge(sys_clk)) then
            rx_in_buf <= rx_in;
            rx_in_read <= rx_in_buf;
        end if;
    end process p_rx_buffer;
    
    rx_FSM: process(sys_clk)
        variable bit_index : integer range 0 to msg_length - 1 := 0;
        variable sys_clk_count : integer range 0 to baud_freq_max_count := 0;
    begin
        if(rising_edge(sys_clk)) then
            if(reset = '1') then
                rx_state <= IDLE;
                rx_active <= '0';
                rx_done <= '0';
                rx_data_out_reg <= (others => '0');
                
                bit_index := 0;
                sys_clk_count := 0;
            else
                case rx_state is
                    when IDLE =>
                        rx_active <= '0';
                        rx_done <= '0';
                        if(sys_clk_count = baud_freq_x16_max_count) then
                            sys_clk_count := 0;
                            if(rx_in_read = '0') then
                                rx_state <= START;
                            else
                                rx_state <= IDLE;
                            end if;
                        else
                            sys_clk_count := sys_clk_count + 1;
                            rx_state <= IDLE;
                        end if;
                    when START =>
                        if(sys_clk_count = (baud_freq_max_count - 1) / 2) then -- Sample middle of the bit
                            sys_clk_count := 0;
                            
                            if(rx_in_read = '0') then
                                rx_active <= '1';
                                rx_state <= RX;
                            else
                                rx_state <= IDLE; -- False alarm
                            end if;
                        else
                            sys_clk_count := sys_clk_count + 1;
                            rx_state <= START;
                        end if;
                    when RX =>
                        if(sys_clk_count = baud_freq_max_count) then
                            sys_clk_count := 0;
                            rx_data_out_reg(bit_index) <= rx_in_read;
                            
                            if(bit_index = msg_length - 1) then
                                bit_index := 0;
                                rx_active <= '0';
                                rx_state <= STOP;
                            else
                                bit_index := bit_index + 1;
                                rx_state <= RX;
                            end if;
                        else
                            sys_clk_count := sys_clk_count + 1;
                            rx_state <= RX;
                        end if;
                    when STOP =>
                        if(sys_clk_count = baud_freq_max_count) then
                            sys_clk_count := 0;
                            rx_done <= '1';
                            rx_state <= IDLE;
                        elsif(sys_clk_count > 1) then -- delay when rx_done goes high a couple of clks
                            sys_clk_count := sys_clk_count + 1;
                            rx_done <= '1';
                            rx_state <= STOP;
                        else
                            rx_done <= '0';
                            sys_clk_count := sys_clk_count + 1;
                            rx_state <= STOP;
                        end if;
                    when others =>
                        rx_state <= IDLE;
                end case;
            end if;
        end if;
    end process rx_FSM;
    
    rx_data_out <= rx_data_out_reg;
end UART_rx_arch;
