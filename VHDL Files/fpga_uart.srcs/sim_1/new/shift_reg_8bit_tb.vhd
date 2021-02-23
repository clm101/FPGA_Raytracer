library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity shift_reg_8bit_tb is
end shift_reg_8bit_tb;

architecture shift_reg_8bit_tb_impl of shift_reg_8bit_tb is
    constant bitCount : integer := 8;
    component shift_reg_8bit_w_store
        generic(bitCount : integer := 8);
        port(D : in STD_LOGIC; CLK : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR;
            data_store : out STD_LOGIC_VECTOR);
    end component;
    
    component clkdiv
        generic(maxCount : integer);
        port(clk_in : in STD_LOGIC; clk_out : out STD_LOGIC);
    end component;
    
    Signal clk_int : STD_LOGIC;
    Signal clk_sig_int : STD_LOGIC;
    Signal D_int : STD_LOGIC;
    Signal data_int : STD_LOGIC_VECTOR(bitCount - 1 downto 0);
    Signal data_store_int : STD_LOGIC_VECTOR(bitCount - 1 downto 0);
begin
    clkdiv_tb : clkdiv generic map(4) port map(clk_in => clk_int, clk_out => clk_sig_int);
    uut : shift_reg_8bit_w_store generic map(bitCount) port map(D => D_int, CLK => clk_sig_int, data => data_int, data_store => data_store_int);   
    
    -- Clock signal
    process begin
        clk_int <= '1'; wait for 5ns;
        clk_int <= '0'; wait for 5ns;
    end process;
    
    -- Data input
    process begin
        D_int <= '1'; wait for 1ns;
        D_int <= '0'; wait for 3ns; -- 4ns
        D_int <= '1'; wait for 2ns; -- 6ns
    end process;
end shift_reg_8bit_tb_impl;