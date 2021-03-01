library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity shift_reg_8bit_tb is
end shift_reg_8bit_tb;

architecture shift_reg_8bit_tb_impl of shift_reg_8bit_tb is
    constant bitCount : integer := 8;
    
    -- Components
    component shift_reg_8bit_w_store
        generic(bitCount : integer);
        port(D : in STD_LOGIC; CLK : in STD_LOGIC;
            btnLeft, btnCenter, btnRight, btnTop : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR;
            data_store : out STD_LOGIC_VECTOR);
    end component;
    
    component clkdiv
        generic(maxCount : integer);
        port(clk_in : in STD_LOGIC; clk_out : out STD_LOGIC);
    end component;
    
    Signal clk_sig : STD_LOGIC := '0';
    --Signal clk_sig_int : STD_LOGIC;
    Signal D_int : STD_LOGIC := '1';
    Signal data_int : STD_LOGIC_VECTOR(bitCount - 1 downto 0);
    Signal data_store_int : STD_LOGIC_VECTOR(bitCount - 1 downto 0);
    Signal btnLeft_sig, btnCenter_sig, btnRight_sig, btnTop_sig : STD_LOGIC := '0';
begin
    --clkdiv_tb : clkdiv generic map(1) port map(clk_in => clk_int, clk_out => clk_sig_int);
    uut : shift_reg_8bit_w_store generic map(bitCount) port map(D => D_int, CLK => clk_sig, btnLeft => btnLeft_sig, btnCenter => btnCenter_sig, btnRight => btnRight_sig, btnTop => btnTop_sig, data => data_int, data_store => data_store_int);   
    
    -- Clock signal
    process begin
        clk_sig <= '0'; wait for 5ns;
        clk_sig <= '1'; wait for 5ns;
    end process;
    
    -- Data input
    process begin
        D_int <= '0'; btnLeft_sig <= '0'; wait for 10ns; -- 10ns
        D_int <= '0'; wait for 10ns; -- 20ns
        D_int <= '1'; wait for 10ns; -- 30ns
        D_int <= '0'; btnCenter_sig <= '1'; wait for 10ns; -- 40ns
        D_int <= '0'; btnCenter_sig <= '0'; wait for 10ns; -- 50ns
        D_int <= '1'; wait for 10ns; -- 60ns
        D_int <= '1'; wait for 10ns; -- 70ns
        D_int <= '0'; btnLeft_sig <= '1'; wait for 10ns; -- 80ns
    end process;
    
    -- Change RAM address
    process begin
        btnTop_sig <= '0'; wait for 160ns;
        btnTop_sig <= '1'; wait for 10ns; 
        btnTop_sig <= '0'; wait for 140ns;
        btnTop_sig <= '1'; wait for 10ns;
    end process;
end shift_reg_8bit_tb_impl;