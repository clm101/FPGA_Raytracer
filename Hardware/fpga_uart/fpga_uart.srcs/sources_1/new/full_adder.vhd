library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity full_adder is
    port(x, y, carryIn : in STD_LOGIC;
        z, carryOut : out STD_LOGIC);
end full_adder;

architecture full_adder_arch of full_adder is
    Signal ha_sig : STD_LOGIC := '0';
begin
    ha_sig <= x xor y;
    z <= ha_sig xor carryIn;
    carryOut <= (x and y) or (carryIn and ha_sig);
end full_adder_arch;
