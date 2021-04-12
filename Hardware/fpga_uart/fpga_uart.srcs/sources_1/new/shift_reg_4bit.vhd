----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 10:05:05 PM
-- Design Name: 
-- Module Name: shift_reg_4bit - shift_reg_4bit_arch
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

entity shift_reg_4bit is
    port(D, CLK, reset : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR(3 downto 0));
end shift_reg_4bit;

architecture shift_reg_4bit_arch of shift_reg_4bit is
    component shift_reg_2bit
        port(D, CLK, reset : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR(1 downto 0));
    end component;
    Signal data_bridge : STD_LOGIC_VECTOR(1 downto 0);
begin
    reg1 : shift_reg_2bit port map(D => D, CLK => CLK, reset => reset, data => data_bridge);
    reg2 : shift_reg_2bit port map(D => data_bridge(1), CLK => CLK, reset => reset, data => data(3 downto 2));
    data(1 downto 0) <= data_bridge;
end shift_reg_4bit_arch;
