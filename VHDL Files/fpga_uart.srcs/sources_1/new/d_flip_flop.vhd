----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 06:00:47 PM
-- Design Name: 
-- Module Name: d_flip_flop - d_flip_flop_struct
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

entity d_flip_flop is
    port(D, CLK, reset : in STD_LOGIC;
        Q : out STD_LOGIC);
end d_flip_flop;

--architecture d_flip_flop_struct of d_flip_flop is
--    component d_latch
--        port(D, CLK : in STD_LOGIC;
--            Q : out STD_LOGIC);
--    end component;
--    Signal D_latch2, CLK_bar, Q_latch1 : STD_LOGIC;
--begin
--    CLK_bar <= not CLK;
--    Latch1: d_latch port map(D => D, CLK => CLK_bar, Q => Q_latch1);
    
--    D_latch2 <= Q_latch1;

--    Latch2: d_latch port map(D => D_latch2, CLK => CLK, Q => Q);
--end d_flip_flop_struct;

architecture d_flipflop_behav of d_flip_flop is
begin
    process(CLK) begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                Q <= '0';
            else
                Q <= D;
            end if;
        end if;
    end process;
end d_flipflop_behav;
