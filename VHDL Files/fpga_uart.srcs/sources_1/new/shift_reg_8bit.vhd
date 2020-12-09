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
    component shift_reg_4bit
        port(D, CLK : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    component clkdiv generic(numOfBits : integer; max_count : integer);
                    port(clk_in : in STD_LOGIC; clk_out : out STD_LOGIC);
    end component;
    
    Signal data_bridge, clk_sig : STD_LOGIC;
begin
    clkcom : clkdiv generic map(26, 50000000)
                     port map(clk_in => CLK, clk_out => clk_sig);
                     
    data(3) <= data_bridge;
    reg1 : shift_reg_4bit port map(D => D, CLK => clk_sig, data => data(3 downto 0));
    reg2 : shift_reg_4bit port map(D => data_bridge, CLK => clk_sig, data => data(7 downto 4));

end shift_reg_8bit_arch;
