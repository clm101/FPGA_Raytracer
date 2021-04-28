library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rx_dword is
    port(
        clk : in STD_LOGIC;
        rx_done : in STD_LOGIC;
        rxData : in STD_LOGIC_VECTOR(7 downto 0);
        run : in STD_LOGIC;
        done : out STD_LOGIC;
        data : out STD_LOGIC_VECTOR(31 downto 0));
end entity rx_dword;

architecture rx_dword_arch of rx_dword is
    Signal rx_done_r, rx_done_r_prev : STD_LOGIC := '0';
begin
    process(clk) begin
        if(rising_edge(clk)) then
            rx_done_r_prev <= rx_done_r;
            rx_done_r <= rx_done;
        end if;
    end process;
    
    process(clk) 
        variable i : integer := 0;
    begin
        if(rising_edge(clk)) then
            if(run = '1') then
                if(rx_done_r = '1' and rx_done_r_prev = '0') then
                    data(8 * i + 7 downto 8 * i) <= rxData;
                    i := i + 1;
                    if(i = 4) then
                        i := 0;
                        done <= '1';
                    end if;
                end if;
            else
                done <= '0';
            end if;
        end if;
    end process;
end architecture rx_dword_arch;