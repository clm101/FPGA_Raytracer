library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adders_tb is

end adders_tb;

architecture adders_tb_arch of adders_tb is
    component ripple_carry_adder
        port(num1, num2 : in STD_LOGIC_VECTOR(3 downto 0);
            result : out STD_LOGIC_VECTOR(4 downto 0));
    end component;
    
    component carry_lookahead_adder
        port(num1, num2 : in STD_LOGIC_VECTOR(3 downto 0);
            result : out STD_LOGIC_VECTOR(4 downto 0));
    end component;
    
    Signal num1_1, num1_2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    Signal num2_1, num2_2 : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    Signal result_1 : STD_LOGIC_VECTOR(4 downto 0);
    Signal result_2 : STD_LOGIC_VECTOR(4 downto 0);
begin
    uut1 : ripple_carry_adder port map(
        num1 => num1_1, num2 => num2_1, result => result_1);
    uut2 : carry_lookahead_adder port map(
        num1 => num1_2, num2 => num2_2, result => result_2);
    num1_2 <= num1_1;
    num2_2 <= num2_1;
    
    process is
    begin
        num1_1 <= X"5";
        num2_1 <= X"6";
        wait for 10ns;
        
        num1_1 <= X"F";
        num2_1 <= X"F";
        wait for 10ns;
        
        num1_1 <= X"E";
        num2_1 <= X"3";
        wait for 10ns;    
    end process;


end adders_tb_arch;
