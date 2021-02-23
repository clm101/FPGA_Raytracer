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

entity shift_reg_8bit_w_store is
    generic(bitCount : integer := 8);
    port(D, CLK : in STD_LOGIC;
        data : out STD_LOGIC_VECTOR(bitCount - 1 downto 0);
        data_store : out STD_LOGIC_VECTOR(bitCount - 1 downto 0));
end shift_reg_8bit_w_store;

architecture shift_reg_8bit_w_store_arch of shift_reg_8bit_w_store is
    function ceil_logb2(n : integer) return integer is
        variable x : integer := n;
        variable ret : integer := 0;
    begin
        while(x /= 0) loop
            x := x / 2;
            ret := ret + 1;
        end loop;
        return ret;
    end ceil_logb2;

    component shift_reg_generic
        generic(numOfBits : integer);
        port(d : in STD_LOGIC; clk : in STD_LOGIC; data : out STD_LOGIC_VECTOR);
    end component;
    
    component register_generic
        generic(bitCount : integer);
        port(en : in STD_LOGIC; D : in STD_LOGIC_VECTOR; Q : out STD_LOGIC_VECTOR);
    end component;
    
    component clkdiv
        generic(maxCount : integer);
        port(clk_in : in STD_LOGIC; clk_out : out STD_LOGIC);
    end component;
    
    Signal data_sig : STD_LOGIC_VECTOR(bitCount - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, bitCount);
    Signal data_store_sig : STD_LOGIC_VECTOR(bitCount - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, bitCount);
    Signal bit_counter : integer := 0;
    Signal en_sig : STD_LOGIC := '0';
    Signal clk_sig : STD_LOGIC;
begin 
    clkdivcom : clkdiv generic map(5000000) port map(clk_in => CLK, clk_out => clk_sig); 
    shift_reg : shift_reg_generic generic map(bitCount) port map(d => D, clk => clk_sig, data => data_sig);
    data_reg: register_generic generic map(bitCount) port map(en => en_sig, D => data_sig, Q => data_store);
     
    data <= data_sig; 
     
    -- Count the number of reads
    process(clk_sig) begin
        if(rising_edge(clk_sig)) then
            --data_sig <= (data_sig(bitCount - 2 downto 0) & D);
            if(bit_counter = bitCount) then
                bit_counter <= 0;
                en_sig <= '1';
            else
                en_sig <= '0';
                bit_counter <= bit_counter + 1;
            end if;
        end if;
    end process;

end shift_reg_8bit_w_store_arch;
