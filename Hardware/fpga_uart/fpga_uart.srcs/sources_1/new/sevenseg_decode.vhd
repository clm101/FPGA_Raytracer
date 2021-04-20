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
                b"10011111" when data_in = X"1" else
                b"00100101" when data_in = X"2" else
                b"00001101" when data_in = X"3" else
                b"10011001" when data_in = X"4" else
                b"01001001" when data_in = X"5" else
                b"01000001" when data_in = X"6" else
                b"00011111" when data_in = X"7" else
                b"00000001" when data_in = X"8" else
                b"00001001" when data_in = X"9" else
                b"00010001" when data_in = X"A" else
                b"11000001" when data_in = X"B" else
                b"01100011" when data_in = X"C" else
                b"10000101" when data_in = X"D" else
                b"01100001" when data_in = X"E" else
                b"01110001" when data_in = X"F" else
                b"00000000";
end sevenseg_decode_arch;
