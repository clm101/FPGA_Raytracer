library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_spam is
    generic(baud_rate : integer := 9600);
    port(clk, rx : in STD_LOGIC;
        tx : out STD_LOGIC);
end UART_spam;

architecture UART_spam_arch of UART_spam is
component UART_Interface
        generic(baud_rate : integer := 9600);
        port(clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            rx_in : in STD_LOGIC;
            rx_active : out STD_LOGIC;
            rx_done : out STD_LOGIC;
            rx_data_out : out STD_LOGIC_VECTOR(7 downto 0);
            tx_start : in STD_LOGIC;
            tx_data_in : in STD_LOGIC_VECTOR(7 downto 0);
            tx_active : out STD_LOGIC;
            tx_done : out STD_LOGIC;
            tx_data_out : out STD_LOGIC);
    end component;
    
    Signal reset : STD_LOGIC := '0';
    Signal rx_active : STD_LOGIC;
    Signal tx_start_r : STD_LOGIC := '1';
    Signal rx_data_out_r : STD_LOGIC_VECTOR(7 downto 0) := X"41";
    Signal tx_active : STD_LOGIC;
    Signal tx_done : STD_LOGIC;
begin
    uart : UART_Interface
        generic map(baud_rate)
        port map(
            clk => clk,
            reset => reset,
            rx_in => rx,
            rx_active => rx_active,
            rx_done => open,
            rx_data_out => open,
            tx_start => tx_start_r,
            tx_data_in => rx_data_out_r,
            tx_active => tx_active,
            tx_done => tx_done,
            tx_data_out => tx);
end UART_spam_arch;
