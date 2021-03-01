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
        btnLeft, btnCenter, btnRight, btnTop : in STD_LOGIC;
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
    
    TYPE state IS (S0, S1, S2);
    Signal PS, NS : state;

    component shift_reg_generic
        generic(numOfBits : integer);
        port(d : in STD_LOGIC; clk : in STD_LOGIC; en : in STD_LOGIC; data : out STD_LOGIC_VECTOR);
    end component;
    
--    component register_generic
--        generic(bitCount : integer);
--        port(en : in STD_LOGIC; D : in STD_LOGIC_VECTOR; Q : out STD_LOGIC_VECTOR);
--    end component;
    
    component blk_mem_gen_0
        port(clka : in STD_LOGIC; ena : in STD_LOGIC; wea : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(2 downto 0); dina : in STD_LOGIC_VECTOR(7 downto 0);
            douta : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    
--    component clkdiv
--        generic(maxCount : integer);
--        port(clk_in : in STD_LOGIC; clk_out : out STD_LOGIC);
--    end component;
    
    component ButtonToggle
        generic(restCount : integer; DefaultOutput : STD_LOGIC);
        port(T : in STD_LOGIC; CLK : in STD_LOGIC; Q : out STD_LOGIC);
    end component;
    
    Signal data_sig : STD_LOGIC_VECTOR(bitCount - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, bitCount);
    Signal data_store_sig : STD_LOGIC_VECTOR(bitCount - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, bitCount);
    Signal bit_counter : integer := 0;
    Signal en_sig : STD_LOGIC := '1';
    Signal we_sig : STD_LOGIC_VECTOR(0 downto 0) := b"0";
    Signal addr_sig : STD_LOGIC_VECTOR(2 downto 0) := b"000";
    Signal clk_sig : STD_LOGIC;
    Signal btn_en_sig : STD_LOGIC := '1';
    --Signal reg_sig : STD_LOGIC_VECTOR(bitCount - 1 downto 0) := CONV_STD_LOGIC_VECTOR(0, bitCount);
    Signal btnVector : STD_LOGIC_VECTOR(2 downto 0);
begin
    btnVector(0) <= btnRight;
    btnVector(1) <= btnCenter;
    btnVector(2) <= btnLeft;
    
    --clkdivcom : clkdiv generic map(5000000) port map(clk_in => CLK, clk_out => clk_sig); 
    clk_sig <= CLK;
    shift_reg : shift_reg_generic generic map(bitCount) port map(d => D, clk => clk_sig, en => btn_en_sig, data => data_sig);
    --data_reg: register_generic generic map(bitCount) port map(en => en_sig, D => data_sig, Q => reg_sig);
    rammod : blk_mem_gen_0 port map(clka => CLK, ena => en_sig, wea => we_sig, addra => addr_sig, dina => data_sig, douta => data_store);
    pause : ButtonToggle generic map(0, '1') port map(T => btnTop, CLK => CLK, Q => btn_en_sig);
     
    data <= data_sig;

    -- Count the number of reads
    process(clk_sig) begin
        if(rising_edge(clk_sig) and btn_en_sig = '1') then
            if(bit_counter = (bitCount - 1)) then
                we_sig <= b"1";
                bit_counter <= 0;
            else
                we_sig <= b"0";
                bit_counter <= bit_counter + 1;
            end if;
        end if;
    end process;
    
--    process(CLK)
--        variable btnVectorTmp : STD_LOGIC_VECTOR(2 downto 0);
--    begin
--        if(rising_edge(CLK) and (btnVector /= btnVectorTmp)) then
--            addr_sig <= btnVector xor btnVectorTmp;
--        end if;
--    end process;
    
    -- State Machine
    SYNC_STATE : process(CLK)
    begin
        if(rising_edge(CLK)) then
            PS <= NS;
        end if;
    end process;
    
    -- Button(State) -> Address
    OUTPUT_DECODE : process(PS)
    begin
        case(PS) is
            when S0 =>
                addr_sig <= b"000";
            when S1 =>
                addr_sig <= b"001";
            when S2 =>
                addr_sig <= b"010";
        end case;
    end process;
    
    NEXT_STATE_DECODE : process(btnVector)
    begin
        case(btnVector) is
            when b"100" =>
                NS <= S0;
            when b"010" =>
                NS <= S1;
            when b"001" =>
                NS <= S2;
            when others =>
                NS <= PS;
        end case;
    end process;

end shift_reg_8bit_w_store_arch;
