library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_impl_tb is
end uart_impl_tb;

architecture Behavioral of uart_impl_tb is
    constant baud_rate : integer := 9600;
    constant clk_freq : integer := 100_000_000;
    constant clk_period : time := 1 sec / Real(clk_freq);
    constant bit_period : time := 1 sec / baud_rate;
    
    component UART_echo
        --generic(baud_rate : integer);
        port(clk : in STD_LOGIC;
            Rx : in STD_LOGIC;
            reset : in STD_LOGIC;
            Tx : out STD_LOGIC);
    end component;
    
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
    
    Signal clk, rx : STD_LOGIC := '0';
    Signal tx : STD_LOGIC;
    
    Signal an : STD_LOGIC_VECTOR(3 downto 0);
    Signal seg : STD_LOGIC_VECTOR(7 downto 0);
    
    Signal msg : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
    Signal tb_data_out : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    Signal baud_clk : STD_LOGIC := '0';
    
    Signal reset : STD_LOGIC := '0';
begin
    uut : UART_echo 
        --generic map(baud_rate)
        port map(
            clk => clk,
            Rx => rx,
            reset => reset,
            Tx => tx);
            
    clk <= not clk after (clk_period / 2);
    baud_clk <= not baud_clk after (bit_period / 2);
    
    process is begin
--        for i in 0 to 1 loop
--            wait for bit_period;
--        end loop;
--        rx <= '1';
--        wait for bit_period;
        rx <= '1';
        
        msg <= X"E4";
        wait until rising_edge(clk);
        proc_rx_test(msg, rx);
        for i in 0 to 100 loop
            wait for bit_period;
        end loop;
        
--        msg <= X"C2";
--        wait until rising_edge(clk);
--        proc_rx_test(msg, rx);
--        for i in 0 to 12 loop
--            wait for bit_period;
--        end loop;
        
--        msg <= X"AA";
--        wait until rising_edge(clk);
--        proc_rx_test(msg, rx);
--        for i in 0 to 12 loop
--            wait for bit_period;
--        end loop;

        
        assert false report "Tests complete" severity failure;
    end process;
end Behavioral;
