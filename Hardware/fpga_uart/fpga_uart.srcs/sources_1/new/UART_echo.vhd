library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_echo is
    generic(baud_rate : integer := 19200;
            byte_size : integer := 1);
    port(clk, rx, reset_counter : in STD_LOGIC;
        tx : out STD_LOGIC;
        sevseg_data : out STD_LOGIC_VECTOR(7 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0));
end UART_echo;

architecture UART_echo_arch of UART_echo is
    component UART_Interface
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
    end component;
    
    component sevseg_ctrl
        port(clk, reset, inc_sig : in STD_LOGIC;
            data_out : out STD_LOGIC_VECTOR(7 downto 0);
            an : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    Signal reset : STD_LOGIC := '0';
    Signal rx_active : STD_LOGIC;
    Signal tx_start_r : STD_LOGIC := '0';
    Signal rx_data_out_r : STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0);
    Signal tx_active : STD_LOGIC;
    Signal tx_done : STD_LOGIC;
    
    Signal byte_counter : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    Signal sevseg_in : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    Signal tx_start_prev : STD_LOGIC := '0';
begin
    uart : UART_Interface
        generic map(baud_rate)
        port map(
            clk => clk,
            reset => reset,
            rx_in => rx,
            rx_active => rx_active,
            rx_done => tx_start_r,
            rx_data_out => rx_data_out_r,
            tx_start => tx_start_r,
            tx_data_in => rx_data_out_r,
            tx_active => tx_active,
            tx_done => tx_done,
            tx_data_out => tx);
    sevseg : sevseg_ctrl
        port map(
            clk => clk,
            reset => reset_counter,
            inc_sig => tx_start_r,
            data_out => sevseg_data,
            an => an
        );
end UART_echo_arch;
