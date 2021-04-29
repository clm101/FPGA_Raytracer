library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity carry_lookahead_adder is
    generic(width : natural := 4);
    port(clk: in STD_LOGIC;
        --run : in STD_LOGIC;
        num1, num2 : in STD_LOGIC_VECTOR(width - 1 downto 0);
        --ready : out STD_LOGIC;
        result : out STD_LOGIC_VECTOR(width downto 0));
end carry_lookahead_adder;

architecture carry_lookahead_adder_arch of carry_lookahead_adder is
    component full_adder
        port(x, y, carryIn : in STD_LOGIC;
        z, carryOut : out STD_LOGIC);
    end component;
    
    Signal P, G, num1_r, num2_r : STD_LOGIC_VECTOR(width - 1 downto 0) := (others => '0');
    Signal C, C_r, result_r : STD_LOGIC_VECTOR(width downto 0) := (others => '0');
    
    type adder_state_t is (STEP1, STEP2, PAUSE);
    Signal adder_state : adder_state_t := STEP1;
begin
    adder: for i in 0 to width - 1 generate
        full_adder_template : full_adder port map(
            x => num1_r(i),
            y => num2_r(i),
            carryIn => C_r(i),
            z => result_r(i),
            carryOut => open);
    end generate adder;
    
    signals : for i in 0 to width - 1 generate
        G(i) <= num1(i) and num2(i);
        P(i) <= num1(i) or num2(i);
        C(i + 1) <= G(i) or (P(i) and C(i));
    end generate signals;
        
    result_r(width) <= C_r(width);
    
    process(clk) begin
        if(rising_edge(clk)) then
            for i in 0 to 1 loop
                case i is
                    when 0 =>
                        num1_r <= num1;
                        num2_r <= num2;
                        C_r <= C;
                    when 1 =>
                        result <= result_r;
                end case;
            end loop;
--            if(run = '1') then
--                case adder_state is 
--                    when STEP1 =>
--                        ready <= '0';
--                        C <= C_r;
--                        adder_state <= STEP2;
--                    when STEP2 =>
--                        ready <= '1';
--                        result <= result_r;
--                        adder_state <= PAUSE;
--                    when PAUSE =>
--                        adder_state <= STEP1;
--                    end case;
--            else
--                ready <= '0';
--                adder_state <= STEP1;
--            end if;
        end if;
    end process;
end carry_lookahead_adder_arch;
