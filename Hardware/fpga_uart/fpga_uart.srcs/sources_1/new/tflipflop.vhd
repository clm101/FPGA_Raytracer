library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tflipflop is
    port(T, CLK : in STD_LOGIC;
        Q : out STD_LOGIC);
end tflipflop;

architecture tflipflop_arch of tflipflop is

begin
    process(CLK)
        variable tmp : STD_LOGIC := '0';
    begin
        if(rising_edge(CLK)) then
            tmp := T xor tmp;
        end if;
        Q <= tmp;
    end process;
end tflipflop_arch;
