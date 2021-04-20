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

entity sevseg_ctrl is
    port(
        clk, reset, inc_sig : in STD_LOGIC;
        data_out : out STD_LOGIC_VECTOR(7 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0));
end sevseg_ctrl;

architecture sevseg_ctrl_arch of sevseg_ctrl is
    component sevenseg_decode
        port(data_in : in STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
    Signal inc_sig_r_prev : STD_LOGIC := '0';
    Signal inc_sig_r : STD_LOGIC := '0';
    Signal byte_counter : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    Signal sevseg_in : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin
    sevseg : sevenseg_decode
        port map(
            data_in => sevseg_in,
            data_out => data_out);
            
    process(clk)
    begin
        if(rising_edge(clk)) then
            inc_sig_r <= inc_sig;
            inc_sig_r_prev <= inc_sig_r;
        end if;
    end process;
    
    process(clk)
        variable clk_counter : integer := 0;
        variable digit_index : integer := 0;
        constant max_clk_count : integer := 100_000;
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                byte_counter <= (others => '0');
            elsif(inc_sig_r_prev = '0' and inc_sig_r = '1') then
                byte_counter <= byte_counter + 1;
            end if;
            
            if(clk_counter = max_clk_count - 1) then
                clk_counter := 0;
                if(digit_index = 3) then
                    digit_index := 0;
                else
                    digit_index := digit_index + 1;
                end if;
            else
                clk_counter := clk_counter + 1;
            end if;
            
            case digit_index is
                when 0 => 
                    sevseg_in <= byte_counter(3 downto 0);
                    an <= "1110";
                when 1 =>
                    sevseg_in <= byte_counter(7 downto 4);
                    an <= "1101";
                when 2 =>
                    sevseg_in <= byte_counter(11 downto 8);
                    an <= "1011";
                when 3 =>
                    sevseg_in <= byte_counter(15 downto 12);
                    an <= "0111";
                when others =>
                    sevseg_in <= byte_counter(3 downto 0);
                    an <= "0111";
            end case;
        end if;
    end process;

end sevseg_ctrl_arch;
