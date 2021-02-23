----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/14/2020 07:10:27 PM
-- Design Name: 
-- Module Name: register_arch - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_generic is
    generic(bitCount : integer);
    port(en : in STD_LOGIC;
        D : in STD_LOGIC_VECTOR(bitCount - 1 downto 0);
        Q : out STD_LOGIC_VECTOR(bitCount - 1 downto 0));
end register_generic;

architecture Behavioral of register_generic is
begin
    process(en) begin
        if(rising_edge(en)) then
            Q <= D;
        end if;
    end process;
    
end Behavioral;
