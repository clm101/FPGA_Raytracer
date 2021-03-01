library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clkdiv is
    generic(maxCount : integer := 100000000);
    port(clk_in : in STD_LOGIC;
        clk_out : out STD_LOGIC);
end clkdiv;

architecture clkdiv_arch of clkdiv is
    function ceil_logb2(n : integer) return integer is
        variable x : integer := n;
        variable ret : integer := 0;
    begin
        while(x /= 0) loop
            x := x / 2;
            ret := ret + 1;
        end loop;
        return ret;
    end ceil_logb2;
    
    constant numOfBits : integer := ceil_logb2(maxCount);

    Signal counter : STD_LOGIC_VECTOR(numOfBits - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, numOfBits);
    Signal clktmp : STD_LOGIC := '0';
begin
    clk_out <= clktmp;
    
    process(clk_in) begin
        if(rising_edge(clk_in)) then
            if(counter = maxCount - 1) then
                counter <= CONV_STD_LOGIC_VECTOR(0, numOfBits);
                clktmp <= not clktmp;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end clkdiv_arch;
