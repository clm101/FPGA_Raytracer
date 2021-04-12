library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_sevseg is
    port(
        clk : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(7 downto 0);
        tx_set : in STD_LOGIC;
        rx_set : in STD_LOGIC;
        an : out STD_LOGIC_VECTOR(3 downto 0);
        data_out : out STD_LOGIC_VECTOR(7 downto 0));
end uart_sevseg;

architecture uart_sevseg_arch of uart_sevseg is
    constant clk_freq : integer := 100_000_000;
    constant sevseg_freq : integer := 1_000;
    constant max_clk_count : integer := clk_freq / sevseg_freq;
    
    Signal tx_store : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    Signal rx_store : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    
    component sevenseg_decode
        port(
            data_in : in STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    Signal tx_lo_out, tx_hi_out, rx_lo_out, rx_hi_out : STD_LOGIC_VECTOR(7 downto 0);
    Signal an_sig : STD_LOGIC_VECTOR(3 downto 0) := X"0";
begin
    an <= an_sig;
    tx_low : sevenseg_decode
        port map(data_in => tx_store(3 downto 0), data_out => tx_lo_out);
    tx_hi : sevenseg_decode
        port map(data_in => tx_store(7 downto 4), data_out => tx_hi_out);
    rx_low : sevenseg_decode
        port map(data_in => rx_store(3 downto 0), data_out => rx_lo_out);
    rx_hi : sevenseg_decode
        port map(data_in => rx_store(7 downto 4), data_out => rx_hi_out);

    process(clk)
        variable clk_count : integer := 0;
        variable nib_index : integer := 0;
    begin
        if(rising_edge(clk)) then
            if(tx_set = '1') then
                tx_store <= data_in;
            end if;
            if(rx_set = '1') then
                rx_store <= data_in;
            end if;
            
            if(clk_count = max_clk_count) then
                clk_count := 0;
                if(nib_index = 3) then
                    nib_index := 0;
                else
                    nib_index := nib_index + 1;
                end if;
                
                an_sig <= (others => '1');
                an_sig(nib_index) <= '0';
            else
                clk_count := clk_count + 1;
            end if;
            
            case nib_index is
            when 0 =>
                data_out <= tx_lo_out;
            when 1 =>
                data_out <= tx_hi_out;
            when 2 =>
                data_out <= rx_lo_out;
            when 3 =>
                data_out <= rx_hi_out;
            when others =>
                data_out <= b"00000000";
            end case;
        end if;
    end process;
end uart_sevseg_arch;
