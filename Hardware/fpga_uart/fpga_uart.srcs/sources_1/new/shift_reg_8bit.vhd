----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 10:15:05 PM
-- Design Name: 
-- Module Name: shift_reg_8bit - shift_reg_8bit_arch
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

entity shift_reg_8bit is
    port(D, CLK : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR(7 downto 0));
end shift_reg_8bit;

architecture shift_reg_8bit_arch of shift_reg_8bit is
    Signal data_sig : STD_LOGIC_VECTOR(7 downto 0) := X"00";
begin
    data <= data_sig;
    
    process(CLK) begin
        if(rising_edge(CLK)) then
            data_sig <= (data_sig(6 downto 0) & D);
        end if;
    end process;
end shift_reg_8bit_arch;
