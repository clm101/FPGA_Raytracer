library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ButtonToggle is
    generic(restCount : integer := 80; DefaultOutput : STD_LOGIC := '0');
    port(T, CLK : in STD_LOGIC;
        Q : out STD_LOGIC);
end ButtonToggle;

architecture buttontoggle_arch of ButtonToggle is

begin
    process(CLK)
        variable tmp : STD_LOGIC := DefaultOutput;
        variable clkCount : integer := 0;
    begin
        if(rising_edge(CLK)) then
            if(clkCount = restCount) then
                clkCount := 0;
                tmp := T xor tmp;
            else
                clkCount := clkCount + 1;
            end if;
        end if;
        Q <= tmp;
    end process;
end buttontoggle_arch;
