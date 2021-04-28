library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ripple_carry_adder is
    --generic(width : natural);
    port(num1, num2 : in STD_LOGIC_VECTOR(3 downto 0);
        result : out STD_LOGIC_VECTOR(4 downto 0));
end ripple_carry_adder;

architecture ripple_carry_adder_arch of ripple_carry_adder is
    Signal carry : STD_LOGIC_VECTOR(3 downto 0);
    
    component full_adder
        port(x, y, carryIn : in STD_LOGIC;
        z, carryOut : out STD_LOGIC);
    end component;
begin
    bit0 : full_adder port map(
        x => num1(0),
        y => num2(0),
        carryIn => '0',
        z => result(0),
        carryOut => carry(0));
    bit1 : full_adder port map(
        x => num1(1),
        y => num2(1),
        carryIn => carry(0),
        z => result(1),
        carryOut => carry(1));
    bit2 : full_adder port map(
        x => num1(2),
        y => num2(2),
        carryIn => carry(1),
        z => result(2),
        carryOut => carry(2));
    bit3 : full_adder port map(
        x => num1(3),
        y => num2(3),
        carryIn => carry(2),
        z => result(3),
        carryOut => carry(3));
    result(4) <= carry(3);


end ripple_carry_adder_arch;
