library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_ctrl is
    generic(baud_rate : integer := 19200;
            byte_size : integer := 1);
    port(clk, rx, reset_counter : in STD_LOGIC;
        tx : out STD_LOGIC;
        sevseg_data : out STD_LOGIC_VECTOR(7 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0));
end uart_ctrl;

architecture uart_ctrl_arch of uart_ctrl is
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
    
    type oper_state_t is (IDLE, CTRL1, CTRL2, ECHO);
    Signal oper_state : oper_state_t := IDLE;
    Signal oper_state_next : oper_state_t := IDLE;
    
    Signal reset : STD_LOGIC := '0';
    Signal rx_active : STD_LOGIC;
    Signal rx_done : STD_LOGIC;
    Signal tx_start : STD_LOGIC := '0';
    Signal rx_data_out : STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0);
    Signal tx_data_in : STD_LOGIC_VECTOR(8 * byte_size - 1 downto 0) := (others => '0');
    Signal tx_active : STD_LOGIC;
    Signal tx_done : STD_LOGIC;
    
    Signal busy : STD_LOGIC := '1';
    
    Signal rx_done_r : STD_LOGIC := '0';
    Signal rx_done_r_prev : STD_LOGIC := '0';
    Signal tx_done_r : STD_LOGIC := '0';
    Signal tx_done_r_prev : STD_LOGIC := '0';
    
    Signal echo_int : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    type echo_state_t is (RECV, TRAN);
    Signal echo_state : echo_state_t := RECV; 
begin
    uart : UART_Interface
        generic map(baud_rate)
        port map(
            clk => clk,
            reset => reset,
            rx_in => rx,
            rx_active => rx_active,
            rx_done => rx_done,
            rx_data_out => rx_data_out,
            tx_start => tx_start,
            tx_data_in => tx_data_in,
            tx_active => tx_active,
            tx_done => tx_done,
            tx_data_out => tx);
    sevseg : sevseg_ctrl
        port map(
            clk => clk,
            reset => reset_counter,
            inc_sig => tx_start,
            data_out => sevseg_data,
            an => an
        );
    
    process(clk) begin
        if(rising_edge(clk)) then
            rx_done_r_prev <= rx_done_r;
            rx_done_r <= rx_done;
            
            tx_done_r_prev <= tx_done_r;
            tx_done_r <= tx_done;
        end if;
    end process;
    
    -- The next state is only refreshed on the rising edge of rx_done
    -- It dumps data across tx into the tx buffer on the PC in the time
    -- it takes for the next ctrl byte to be sent
    
    -- The goal is to have this function as some sort of signaling mechanism
    -- to the hardware when a new job is present. It needs to be signaled that
    -- the new job has been caught and is being processed.
    ctrl_sig_decode : process(clk) begin
        if(rising_edge(clk)) then
            if(busy = '0') then
                if(rx_done_r = '1' and rx_done_r_prev = '0') then
                    case rx_data_out is
                        when X"01" =>
                            oper_state_next <= CTRL1;
                        when X"02" =>
                            oper_state_next <= CTRL2;
                        when X"04" =>
                            oper_state_next <= ECHO;
                        when others =>
                            oper_state_next <= IDLE;
                    end case;
                end if;
            else
                oper_state_next <= IDLE;
            end if;
        end if;
    end process ctrl_sig_decode;
    
    process(clk)
        variable i, j, k : integer := 0;
    begin
        if(rising_edge(clk)) then
            case oper_state is
                when IDLE =>
                    tx_start <= '0';
                    oper_state <= oper_state_next;
                    busy <= '0';
                    i := 0;
                when CTRL1 =>
                    busy <= '1';
                    if(i = 3) then
                        tx_start <= '0';
                        oper_state <= IDLE;
                        i := 0;
                    elsif(i = 1) then
                        tx_start <= '1';
                        i := i + 1;
                    else
                        i := i + 1;
                        tx_data_in <= X"41";
                    end if;
                when CTRL2 =>
                    busy  <= '1';
                    if(i = 3) then
                        tx_start <= '0';
                        oper_state <= IDLE;
                        i := 0;
                    elsif(i = 1) then
                        tx_start <= '1';
                        i := i + 1;
                    else
                        i := i + 1;
                        tx_data_in <= X"42";
                    end if;
                when ECHO =>
                    busy <= '1';
                    case echo_state is
                        when RECV =>
                            if(rx_done_r = '1' and rx_done_r_prev = '0') then
                                echo_int(8 * i + 7 downto 8 * i) <= rx_data_out;
                                i := i + 1;
                                if(i = 4) then
                                    echo_state <= TRAN;
                                    i := 0;
                                    j := 0;
                                end if;
                            end if;
                        when TRAN =>
                            if(tx_active = '0') then
                                if(j = 0) then
                                    if(i = 4) then
                                        i := 0;
                                        j := 0;
                                        echo_state <= RECV;
                                        oper_state <= IDLE;
                                    else
                                        tx_data_in <= echo_int(8 * i + 7 downto 8 * i);
                                        i := i + 1;
                                        j := j + 1;
                                    end if;
                                elsif(j = 1) then
                                    tx_start <= '1';
                                end if;
                            else
                                tx_start <= '0';
                                j := 0;
                            end if;
                    end case;
--                    if(j = 0) then
--                        if(rx_done_r = '1' and rx_done_r_prev = '0') then
--                            echo_int(8 * i + 7 downto 8 * i) <= rx_data_out;
--                            i := i + 1;
--                            if(i = 4) then
--                                i := 0;
--                                j := 1;
--                            end if;
--                        end if;
--                    elsif(j = 1) then
--                        if(tx_active = '0') then
--                            if(k = 0) then
--                                tx_data_in <= echo_int(8 * i + 7 downto 8 * i);
--                                k := 1;
--                            elsif(k = 1) then
--                                tx_start <= '1';
--                                i := i + 1;
--                                k := 0;
--                            end if;
--                        else
--                            tx_start <= '0';
--                        end if;
                        
--                        if(i = 4) then
--                            j := 2;
--                            i := 0;
--                        end if;
--                    else
--                        j := 0;
--                        oper_state <= IDLE;
--                    end if;
                when others =>
                    busy <= '1';
                    if(i = 3) then
                        tx_start <= '0';
                        oper_state <= IDLE;
                        i := 0;
                    elsif(i = 1) then
                        tx_start <= '1';
                        i := i + 1;
                    else
                        i := i + 1;
                        tx_data_in <= X"25";
                    end if;
            end case;
        end if;
    end process;
    
end uart_ctrl_arch;
