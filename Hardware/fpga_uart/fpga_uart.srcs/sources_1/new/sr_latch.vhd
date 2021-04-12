----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 12:32:12 PM
-- Design Name: 
-- Module Name: sr_latch - sr_latch_struct
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

entity sr_latch is
    port(S, R : in STD_LOGIC;
        Q, Q_bar : inout STD_LOGIC);
end sr_latch;

architecture sr_latch_behav of sr_latch is
begin
    Q <= R nor Q_bar after 2ns;
    Q_bar <= S nor Q after 2ns;
end sr_latch_behav;
