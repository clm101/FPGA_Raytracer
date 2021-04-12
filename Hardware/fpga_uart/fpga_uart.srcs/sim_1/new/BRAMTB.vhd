library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAMTB is
end BRAMTB;

architecture Behavioral of BRAMTB is
    component
        blk_mem_gen_0 port(addra : in STD_LOGIC_VECTOR(2 downto 0);
                        clka : in STD_LOGIC;
                        dina : in STD_LOGIC_VECTOR(7 downto 0);
                        douta : out STD_LOGIC_VECTOR(7 downto 0);
                        ena : in STD_LOGIC;
                        wea : in STD_LOGIC_VECTOR(0 downto 0));
    end component;
    
    Signal clka_sig, ena_sig : STD_LOGIC := '0';
    Signal addra_sig : STD_LOGIC_VECTOR(2 downto 0) := b"000";
    Signal dina_sig, douta_sig : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    Signal wea_sig : STD_LOGIC_VECTOR(0 downto 0) := "0";    
begin
    uut : blk_mem_gen_0 port map(addra => addra_sig, clka => clka_sig, dina => dina_sig,
                                douta => douta_sig, ena => ena_sig, wea => wea_sig);
    
    -- Clock
    process begin
        clka_sig <= '0'; wait for 5ns;
        clka_sig <= '1'; wait for 5ns;
    end process;
    
    process begin
        ena_sig <= '1'; wea_sig <= "1"; wait for 5ns; -- 5ns
        dina_sig <= X"AA"; wait for 20ns; -- 25ns
        dina_sig <= X"BB"; wait for 20ns; -- 45ns
        addra_sig <= b"001"; wait for 20ns; -- 65ns
        dina_sig <= X"CD"; wait for 20ns; -- 85ns
        wea_sig <= "0"; wait for 4ns; --89ns
        addra_sig <= b"000"; wait for 58ns; -- 147ns
        addra_sig <= b"001"; wait for 58ns; -- 205ns
        ena_sig <= '0'; wait for 20ns; -- 225ns
        addra_sig <= b"000"; wait for 85ns; -- 310ns
        ena_sig <= '1'; wait for 15ns; -- 325ns
        addra_sig <= b"001"; wait for 15ns; -- 340ns
        ena_sig <= '0'; wait for 80ns; -- 420ns
    end process;
end Behavioral;
