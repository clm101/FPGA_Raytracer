----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 08:45:25 PM
-- Design Name: 
-- Module Name: shift_reg_2bit - shift_reg_2bit_arch
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

entity shift_reg_2bit is
    port(CLK, D : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR(1 downto 0));
end shift_reg_2bit;

architecture shift_reg_2bit_arch of shift_reg_2bit is
    component d_flip_flop
        port(D, CLK : in STD_LOGIC;
            Q : out STD_LOGIC);
    end component;
    Signal Q_flip1 : STD_LOGIC;
begin
    reg1 : d_flip_flop port map(CLK => CLK, D => D, Q => data(0));
    reg2 : d_flip_flop port map(CLK => CLK, D => Q_flip1, Q => data(1));
    data(0) <= Q_flip1;
end shift_reg_2bit_arch;
