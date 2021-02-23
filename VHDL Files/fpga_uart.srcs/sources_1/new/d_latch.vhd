----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 05:36:51 PM
-- Design Name: 
-- Module Name: d_latch - d_latch_arch
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

entity d_latch is
    port(D, CLK : in STD_LOGIC;
        Q : out STD_LOGIC);
end d_latch;

architecture d_latch_arch of d_latch is
    component sr_latch
        port(S, R : in STD_LOGIC;
            Q, Q_bar : inout STD_LOGIC);
    end component;
    Signal R_latch, S_latch, Q_sig, Q_bar_sig : STD_LOGIC;
begin
    SRLatch0: sr_latch port map(S => S_latch, R => R_latch, Q => Q_sig, Q_bar => Q_bar_sig);   
    S_latch <= D and CLK;
    R_latch <= (not D) and CLK;
    Q <= Q_sig;
end d_latch_arch;
