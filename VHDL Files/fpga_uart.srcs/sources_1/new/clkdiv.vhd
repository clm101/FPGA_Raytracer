----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 11:25:47 PM
-- Design Name: 
-- Module Name: clkdiv - clkdiv_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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
    generic(numOfBits : integer := 27;
            max_count : integer := 100000000);
    port(clk_in : in STD_LOGIC;
        clk_out : out STD_LOGIC);
end clkdiv;

architecture clkdiv_arch of clkdiv is
    Signal counter : STD_LOGIC_VECTOR(numOfBits - 1 downto 0);
    Signal clktmp : STD_LOGIC := '0';
begin
    clk_out <= clktmp;
    
    process(clk_in) begin
        if(rising_edge(clk_in)) then
            if(counter = max_count - 1) then
                counter <= CONV_STD_LOGIC_VECTOR(0, numOfBits);
                clktmp <= not clktmp;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

end clkdiv_arch;
