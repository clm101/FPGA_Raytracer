library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is
    constant baud_rate : integer := 19200;
    constant clk_freq : integer := 100_000_000;
    constant clk_period : time := 1 sec / Real(clk_freq);
    constant bit_period : time := 1 sec / baud_rate;
    
    component UART_tx is
        generic(
            baud_rate : integer);
        port(
            sys_clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            tx_start : in STD_LOGIC;
            tx_data_in : in STD_LOGIC_VECTOR(7 downto 0);
            tx_active : out STD_LOGIC;
            tx_done : out STD_LOGIC;
            tx_data_out : out STD_LOGIC);
    end component;
    
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
    signal tx_start : STD_LOGIC := '0';
    signal tx_data_in : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_active : STD_LOGIC;
    signal tx_done : STD_LOGIC;
    signal tx_data_out : STD_LOGIC;
    
    signal rx_in : STD_LOGIC := '1';
    signal rx_active : STD_LOGIC;
    signal rx_done : STD_LOGIC;
    signal rx_data_out : STD_LOGIC_VECTOR(7 downto 0);
    
    signal msg : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    
    procedure uart_tx_test(
        msg : in STD_LOGIC_VECTOR(7 downto 0);
        signal data_in : out STD_LOGIC_VECTOR(7 downto 0);
        signal start : out STD_LOGIC) is
    begin
        data_in <= msg;
        wait until rising_edge(sys_clk);
        start <= '1';
        for i in 0 to 10 loop
            if(i = 2) then
                start <= '0';
            end if;
            wait for bit_period;
        end loop;
    end procedure uart_tx_test;
begin
    uut_tx : UART_tx
        generic map(
            baud_rate)
        port map(
            sys_clk => sys_clk,
            reset => reset,
            tx_start => tx_start,
            tx_data_in => tx_data_in,
            tx_active => tx_active,
            tx_done => tx_done,
            tx_data_out => tx_data_out);
    uut_rx : UART_rx
        generic map(
            baud_rate)
        port map(
            sys_clk => sys_clk,
            reset => reset,
            rx_in => tx_data_out,
            rx_active => rx_active,
            rx_done => rx_done,
            rx_data_out => rx_data_out);
    
    sys_clk <= not sys_clk after (clk_period / 2);
    process is
    begin
        msg <= X"FF";
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        uart_tx_test(msg, tx_data_in, tx_start);
        rx_in <= '1';
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        assert rx_data_out = msg report "RX Test Failed - Incorrect byte received" severity failure;
        
        msg <= X"AB";
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        uart_tx_test(msg, tx_data_in, tx_start);
        rx_in <= '1';
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        assert rx_data_out = msg report "RX Test Failed - Incorrect byte received" severity failure;
        
        msg <= X"57";
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        uart_tx_test(msg, tx_data_in, tx_start);
        rx_in <= '1';
        wait until rising_edge(sys_clk);
        wait until rising_edge(sys_clk);
        assert rx_data_out = msg report "RX Test Failed - Incorrect byte received" severity failure;
        
        assert false report "Tests complete" severity failure;
    end process;
    
end Behavioral;
