library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rx_tb is
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is
    constant baud_rate : integer := 19200;
    constant clk_freq : integer := 100_000_000;
    constant clk_period : time := 1 sec / Real(clk_freq);
    constant bit_period : time := 1 sec / baud_rate;
    
    component UART_rx is
        generic(
            baud_rate : integer);
        port(
            sys_clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx_in : in STD_LOGIC;
            rx_active : out STD_LOGIC;
            rx_done : out STD_LOGIC;
            rx_data_out : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    signal sys_clk : STD_LOGIC := '1';
    signal reset : STD_LOGIC := '0';
    
    signal rx_in : STD_LOGIC := '1';
    signal rx_active : STD_LOGIC;
    signal rx_done : STD_LOGIC;
    signal rx_data_out : STD_LOGIC_VECTOR(7 downto 0);
    
    signal msg : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    
    procedure proc_rx_test(
        data : in STD_LOGIC_VECTOR(7 downto 0);
        signal serial_out : out STD_LOGIC) is
    begin
        serial_out <= '0'; wait for bit_period;
        for i in 0 to 7 loop
            serial_out <= data(i);
            wait for bit_period;
        end loop;
        serial_out <= '1'; wait for bit_period;
    end procedure proc_rx_test;
begin
    uut_rx : UART_rx
        generic map(
            baud_rate)
        port map(
            sys_clk => sys_clk,
            reset => reset,
            rx_in => rx_in,
            rx_active => rx_active,
            rx_done => rx_done,
            rx_data_out => rx_data_out);
    
    sys_clk <= not sys_clk after (clk_period / 2);
    process is
    begin
        -- Test reciever
        msg <= X"FF";
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        proc_rx_test(msg, rx_in);
        rx_in <= '1';
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        assert rx_data_out = msg report "RX Test Failed - Incorrect byte received" severity failure;
        
        msg <= X"AB";
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        proc_rx_test(msg, rx_in);
        rx_in <= '1';
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        assert rx_data_out = msg report "RX Test Failed - Incorrect byte received" severity failure;

        assert false report "Tests complete" severity failure;
    end process;
    
end Behavioral;
