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
--    component ripple_carry_adder
--        port(num1, num2 : in STD_LOGIC_VECTOR(3 downto 0);
--            result : out STD_LOGIC_VECTOR(4 downto 0));
--    end component;
    
--    component carry_lookahead_adder
--        port(num1, num2 : in STD_LOGIC_VECTOR(3 downto 0);
--            result : out STD_LOGIC_VECTOR(4 downto 0));
--    end component;
    
    component cla_8bit
        port(clk, carryIn : in STD_LOGIC;
            int1, int2 : in STD_LOGIC_VECTOR(7 downto 0);
            sum : out STD_LOGIC_VECTOR(8 downto 0));
    end component;
    
    Signal clk : STD_LOGIC := '0';
    Signal num1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    Signal num2 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    Signal result : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
begin
--    uut1 : ripple_carry_adder port map(
--        num1 => num1_1, num2 => num2_1, result => result_1);
--    uut2 : carry_lookahead_adder port map(
--        num1 => num1_2, num2 => num2_2, result => result_2);
    uut : cla_8bit port map(
        clk => clk, carryIn => '0', int1 => num1, int2 => num2, sum => result);
        
    clk <= not clk after 5ns;
        
    process is
    begin
        num1 <= X"51";
        num2 <= X"62";
        wait for 10ns;
        
        num1 <= X"F6";
        num2 <= X"F6";
        wait for 10ns;
        
        num1 <= X"E2";
        num2 <= X"31";
        wait for 10ns;    
    end process;


end adders_tb_arch;
