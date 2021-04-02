library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_tx is
    generic(
        baud_rate : integer := 9600);
    port(
        sys_clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        tx_start : in STD_LOGIC;
        tx_data_in : in STD_LOGIC_VECTOR(7 downto 0);
        tx_active : out STD_LOGIC;
        tx_done : out STD_LOGIC;
        tx_data_out : out STD_LOGIC);
end UART_tx;

architecture UART_tx_arch of UART_tx is
    type tx_states_t is (IDLE, START, TX, STOP);
    signal tx_state : tx_states_t := IDLE;

    signal tx_clk : STD_LOGIC := '0';
    
    signal tx_data_in_r : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
begin
    tx_FSM: process(sys_clk)
        constant clk_ticks_per_bit : integer := ((100_000_000 / baud_rate) - 1);
        variable sys_clk_count : integer range 0 to clk_ticks_per_bit := 0;
        variable bit_index : integer range 0 to 7 := 0;
    begin
        if(rising_edge(sys_clk)) then
            case tx_state is
                when IDLE =>
                    tx_active <= '0';
                    tx_done <= '0';
                    tx_data_out <= '1';
                    
                    sys_clk_count := 0;
                    bit_index := 0;
                    
                    if(tx_start = '1') then
                        tx_data_in_r <= tx_data_in;
                        tx_active <= '1';
                        tx_state <= START;
                    else
                        tx_state <= IDLE;
                    end if;
                when START =>
                    tx_data_out <= '0';
                    if(sys_clk_count = clk_ticks_per_bit) then
                        tx_state <= TX;
                        sys_clk_count := 0;
                    else
                        tx_state <= START;
                        sys_clk_count := sys_clk_count + 1;
                    end if;
                when TX =>
                    tx_data_out <= tx_data_in_r(bit_index);
                    if(sys_clk_count = clk_ticks_per_bit) then
                        sys_clk_count := 0;
                        if(bit_index = 7) then
                            bit_index := 0;
                            tx_state <= STOP;
                        else
                            bit_index := bit_index + 1;
                            tx_state <= TX;
                        end if;
                    else
                        sys_clk_count := sys_clk_count + 1;
                        tx_state <= TX;
                    end if;
                when STOP =>
                    tx_data_out <= '1';
                    tx_active <= '0';
                    tx_done <= '1';
                    
                    if(sys_clk_count = clk_ticks_per_bit) then
                        sys_clk_count := 0;
                        tx_state <= IDLE;
                    else
                        sys_clk_count := sys_clk_count + 1;
                        tx_state <= STOP;
                    end if;
                when others =>
                    tx_state <= IDLE;
            end case;
        end if;
    end process tx_FSM;
end UART_tx_arch;
