library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ButtonToggleTB is
end ButtonToggleTB;

architecture Behavioral of ButtonToggleTB is
    component
        ButtonToggle generic(restCount : integer); port(T, CLK : in STD_LOGIC; Q : out STD_LOGIC);
    end component;
    
    Signal T_sig, clk_sig, q_sig : STD_LOGIC := '0';
begin
    uut : ButtonToggle generic map(0) port map(T => T_sig, CLK => clk_sig, Q => q_sig);

    -- Clock
    process begin
        clk_sig <= '0'; wait for 5ns;
        clk_sig <= '1'; wait for 5ns;
    end process;
    
    --Data input
    process begin
        T_sig <= '1'; wait for 7ns; -- 7ns
        T_sig <= '0'; wait for 3ns; -- 10ns
        T_sig <= '1'; wait for 10ns; -- 20ns
        T_sig <= '0'; wait for 13ns; -- 33ns
        T_sig <= '1'; wait for 6ns; -- 39ns
        T_sig <= '0'; wait for 11ns; -- 50ns
        T_sig <= '1'; wait for 30ns; -- 80ns
    end process;
end Behavioral;
