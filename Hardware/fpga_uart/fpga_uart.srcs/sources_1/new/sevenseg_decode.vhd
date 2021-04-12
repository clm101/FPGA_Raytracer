library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sevenseg_decode is
    port(
        data_in : in STD_LOGIC_VECTOR(3 downto 0);
        data_out : out STD_LOGIC_VECTOR(7 downto 0));
end sevenseg_decode;

architecture sevenseg_decode_arch of sevenseg_decode is

begin
    data_out <= b"00000011" when data_in = X"0" else
                b"01100000" when data_in = X"1" else
                b"11011010" when data_in = X"2" else
                b"01100110" when data_in = X"3" else
                b"10110110" when data_in = X"4" else
                b"10111110" when data_in = X"5" else
                b"11100000" when data_in = X"6" else
                b"11111110" when data_in = X"7" else
                b"11110110" when data_in = X"8" else
                b"11101110" when data_in = X"9" else
                b"00111110" when data_in = X"A" else
                b"10011100" when data_in = X"B" else
                b"01111010" when data_in = X"C" else
                b"10011110" when data_in = X"D" else
                b"10001110" when data_in = X"E" else
                b"00000000";
end sevenseg_decode_arch;
