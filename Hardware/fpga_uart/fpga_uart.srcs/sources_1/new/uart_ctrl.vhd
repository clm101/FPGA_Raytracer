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
    
    component rx_dword
        port(clk, rx_done, run : in STD_LOGIC;
            rxData : in STD_LOGIC_VECTOR(7 downto 0);
            done : out STD_LOGIC;
            data : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component carry_lookahead_adder
        generic(width : natural);
        port(clk : in STD_LOGIC;
            --run : in STD_LOGIC;
            num1, num2 : in STD_LOGIC_VECTOR(width - 1 downto 0);
            --ready : out STD_LOGIC;
            result : out STD_LOGIC_VECTOR(width downto 0));
    end component;
    
--    component multiplier
--        port(clk, run : STD_LOGIC;
--            int1, int2 : in STD_LOGIC_VECTOR(31 downto 0);
--            prod : out STD_LOGIC_VECTOR(31 downto 0);
--            ready : out STD_LOGIC);
--    end component;
    
    type oper_state_t is (IDLE, CTRL1, CTRL2, ECHO, ADD, MUL);
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
    Signal echo_int_r : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    type echo_state_t is (RECV, TRAN);
    Signal echo_state : echo_state_t := RECV;
    
    type add_state_t is (RECV1, RECV2, ADD, TRAN);
    Signal add_state : add_state_t := RECV1;
    Signal int1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    Signal int2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    Signal int_sum_r : STD_LOGIC_VECTOR(32 downto 0) := (others => '0');
    Signal int_sum : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    Signal adder_run : STD_LOGIC := '0';
    Signal adder_ready : STD_LOGIC;
    
    procedure get_dw(
        variable i : inout integer;
        variable j : inout integer;
        Signal rx_done : in STD_LOGIC;
        Signal rx_done_prev : in STD_LOGIC;
        Signal rx_data : in STD_LOGIC_VECTOR(7 downto 0);
        Signal echo_data : inout STD_LOGIC_VECTOR(31 downto 0);
        Signal echo_state : inout echo_state_t) is
    begin
        if(rx_done = '1' and rx_done_prev = '0') then
            echo_data(8 * i + 7 downto 8 * i) <= rx_data;
            i := i + 1;
            if(i = 4) then
                echo_state <= TRAN;
                i := 0;
                j := 0;
            end if;
        end if;
    end procedure get_dw;
    
    Signal run_rx_dword_sig : STD_LOGIC := '0';
    Signal done_rx_dword_sig : STD_LOGIC;
    
    type mul_state_t is (RECV1, RECV2, MUL, TRAN);
    Signal mul_state : mul_state_t := RECV1;
    Signal mul_run : STD_LOGIC := '0';
    Signal mul_ready : STD_LOGIC;
    Signal mul_prod, mul_prod_r : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
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
    rx_dword_mod : rx_dword
        port map(
            clk => clk,
            rx_done => rx_done,
            rxData => rx_data_out,
            run => run_rx_dword_sig,
            done => done_rx_dword_sig,
            data => echo_int_r
        );
    adder : carry_lookahead_adder
        generic map(32)
        port map(
            clk => clk,
            --run => adder_run,
            num1 => int1,
            num2 => int2,
            --ready => adder_ready
            result => int_sum_r
        );
--    multiplier_mod : multiplier
--        port map(
--            clk => clk,
--            run => mul_run,
--            int1 => int1,
--            int2 => int2,
--            prod => mul_prod_r,
--            ready => mul_ready);
    
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
                        when X"05" =>
                            oper_state_next <= ADD;
                        when X"06" =>
                            oper_state_next <= MUL;
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
                        -- Initial impl
--                            if(rx_done_r = '1' and rx_done_r_prev = '0') then
--                                echo_int(8 * i + 7 downto 8 * i) <= rx_data_out;
--                                i := i + 1;
--                                if(i = 4) then
--                                    echo_state <= TRAN;
--                                    i := 0;
--                                    j := 0;
--                                end if;
--                            end if;

                        -- Procedure impl
--                            get_dw(i, j, rx_done_r, rx_done_r_prev, rx_data_out, echo_int, echo_state);
                        
                        -- Module impl
                            run_rx_dword_sig <= '1';
                            if(done_rx_dword_sig = '1') then
                                echo_int <= echo_int_r;
                                run_rx_dword_sig <= '0';
                                echo_state <= TRAN;
                            else
                                echo_state <= RECV;
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
                when ADD =>
                    busy <= '1';
                    case add_state is
                        when RECV1 =>
                            run_rx_dword_sig <= '1';
                            if(done_rx_dword_sig = '1') then
                                int1 <= echo_int_r;
                                run_rx_dword_sig <= '0';
                                add_state <= RECV2;
                            else
                                add_state <= RECV1;
                            end if;
                        when RECV2 =>
                            if(run_rx_dword_sig = '1') then
                                if(done_rx_dword_sig = '1') then
                                    int2 <= echo_int_r;
                                    run_rx_dword_sig <= '0';
                                    add_state <= ADD;
                                else
                                    add_state <= RECV2;
                                end if;
                            else
                                run_rx_dword_sig <= '1';
                            end if;
                        when ADD =>
                            -- Output actually might be ready at i = 1
                            if(i = 2) then
                                int_sum <= int_sum_r(31 downto 0);
                                i := 0;
                                add_state <= TRAN;
                            else
                                i := i + 1;
                                add_state <= ADD;
                            end if;
--                            adder_run <= '1';
--                            if(adder_ready = '1') then
--                                adder_run <= '0';
--                                int_sum <= int_sum_r(31 downto 0);
--                                add_state <= TRAN;
--                            else
--                                add_state <= ADD;
--                            end if;
                        when TRAN =>
                            if(tx_active = '0') then
                                if(j = 0) then
                                    if(i = 4) then
                                        i := 0;
                                        j := 0;
                                        add_state <= RECV1;
                                        oper_state <= IDLE;
                                    else
                                        tx_data_in <= int_sum(8 * i + 7 downto 8 * i);
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
--                when MUL =>
--                    busy <= '1';
--                    case mul_state is
--                        when RECV1 =>
--                            run_rx_dword_sig <= '1';
--                            if(done_rx_dword_sig = '1') then
--                                int1 <= echo_int_r;
--                                run_rx_dword_sig <= '0';
--                                mul_state <= RECV2;
--                            else
--                                mul_state <= RECV1;
--                            end if;
--                        when RECV2 =>
--                            if(run_rx_dword_sig = '1') then
--                                if(done_rx_dword_sig = '1') then
--                                    int2 <= echo_int_r;
--                                    run_rx_dword_sig <= '0';
--                                    mul_state <= MUL;
--                                else
--                                    mul_state <= RECV2;
--                                end if;
--                            else
--                                run_rx_dword_sig <= '1';
--                            end if;
--                        when MUL =>
--                            mul_run <= '1';
--                            if(mul_ready = '1') then
--                                mul_run <= '0';
--                                mul_prod <= mul_prod_r;
--                                mul_state <= TRAN;
--                            else
--                                mul_state <= MUL;
--                            end if;
--                        when TRAN =>
--                            if(tx_active = '0') then
--                                if(j = 0) then
--                                    if(i = 4) then
--                                        i := 0;
--                                        j := 0;
--                                        mul_state <= RECV1;
--                                        oper_state <= IDLE;
--                                    else
--                                        tx_data_in <= mul_prod(8 * i + 7 downto 8 * i);
--                                        i := i + 1;
--                                        j := j + 1;
--                                    end if;
--                                elsif(j = 1) then
--                                    tx_start <= '1';
--                                end if;
--                            else
--                                tx_start <= '0';
--                                j := 0;
--                            end if;
--                    end case;
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
