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

entity shift_reg_generic is
    generic(numOfBits : integer := 8);
    port(d : in STD_LOGIC;
        clk : in STD_LOGIC;
        en : in STD_LOGIC := '1';
        data : out STD_LOGIC_VECTOR(numOfBits - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, numOfBits));
end shift_reg_generic;

architecture Behavioral of shift_reg_generic is
    constant msb : integer := numOfBits - 1;
    Signal data_sig : STD_LOGIC_VECTOR(msb downto 0) := CONV_STD_LOGIC_VECTOR(0, numOfBits);
begin
    data <= data_sig;
    
    process(CLK) begin
        if(rising_edge(CLK)) then
            if(en = '1') then
                data_sig <= (data_sig(msb - 1 downto 0) & D);
            end if;
        end if;
    end process;
end Behavioral;
