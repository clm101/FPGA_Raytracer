library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_Interface is
    generic(baud_rate : integer := 9600;
            byte_size : integer := 1);
    port(clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        rx_in : in STD_LOGIC;
        rx_active : out STD_LOGIC;
        rx_done : out STD_LOGIC;
        rx_data_out : out STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0);
        tx_start : in STD_LOGIC;
        tx_data_in : in STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0);
        tx_active : out STD_LOGIC;
        tx_done : out STD_LOGIC;
        tx_data_out : out STD_LOGIC);
end UART_Interface;

architecture UART_Interface_arch of UART_Interface is
    component UART_rx
        generic(
            baud_rate : integer;
            byte_size : integer);
        port(
            sys_clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx_in : in STD_LOGIC;
            rx_active : out STD_LOGIC;
            rx_done : out STD_LOGIC;
            rx_data_out : out STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0));
    end component;
    
    component UART_tx
        generic(
            baud_rate : integer;
            byte_size : integer);
        port(
            sys_clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            tx_start : in STD_LOGIC;
            tx_data_in : in STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0);
            tx_active : out STD_LOGIC;
            tx_done : out STD_LOGIC;
            tx_data_out : out STD_LOGIC);
    end component;
begin
    rx_mod : UART_rx
        generic map(baud_rate, byte_size)
        port map(
            sys_clk => clk,
            reset => reset,
            rx_in => rx_in,
            rx_active => rx_active,
            rx_done => rx_done,
            rx_data_out => rx_data_out);
    tx_mod : UART_tx
        generic map(baud_rate, byte_size)
        port map(
            sys_clk => clk,
            reset => reset,
            tx_start => tx_start,
            tx_data_in => tx_data_in,
            tx_active => tx_active,
            tx_done => tx_done,
            tx_data_out => tx_data_out);
end UART_Interface_arch;
