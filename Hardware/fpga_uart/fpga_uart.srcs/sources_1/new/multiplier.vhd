library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is
    port(
        clk : in STD_LOGIC;
        run : in STD_LOGIC;
        int1 : in STD_LOGIC_VECTOR(31 downto 0);
        int2 : in STD_LOGIC_VECTOR(31 downto 0);
        prod : out STD_LOGIC_VECTOR(31 downto 0);
        ready : out STD_LOGIC);
end multiplier;

architecture multiplier_arch of multiplier is
    component carry_lookahead_adder
        generic(width : natural);
        port(clk, run : in STD_LOGIC;
            num1, num2 : in STD_LOGIC_VECTOR(width - 1 downto 0);
            ready : out STD_LOGIC;
            result : out STD_LOGIC_VECTOR(width downto 0));
    end component;
    
    Signal adder_run : STD_LOGIC := '0';
    Signal adder_ready : STD_LOGIC;
    Signal adder_result : STD_LOGIC_VECTOR(32 downto 0);
    Signal shift_reg : STD_LOGIC_VECTOR(31 downto 0);
    Signal val : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    Signal intermed_prod : STD_LOGIC_VECTOR(31 downto 0);
    
    type mul_state_t is (LOAD, PROC, OUTPUT, PAUSE);
    Signal mul_state : mul_state_t := LOAD;
begin
    adder : carry_lookahead_adder
        generic map(32)
        port map(
            clk => clk,
            run => adder_run,
            num1 => intermed_prod,
            num2 => val,
            result => adder_result,
            ready => adder_ready);
    process(clk)
        variable i, j : integer := 0;
    begin
        if(rising_edge(clk)) then
            if(run = '1') then
                case mul_state is
                when LOAD =>
                    ready <= '0';
                    shift_reg <= int1;
                    intermed_prod <= CONV_STD_LOGIC_VECTOR(32, 0);
                    mul_state <= PROC;
                when PROC =>
                    if(i = 32) then
                        prod <= adder_result(31 downto 0);
                        mul_state <= OUTPUT;
                    else
                        if(j = 0) then
                            shift_reg <= shift_reg(30 downto 0) & '0';
                            j := 1;
                        elsif(j = 1) then
                            case int2(i) is
                            when '0' =>
                                val <= CONV_STD_LOGIC_VECTOR(32, 0);
                            when '1' =>
                                val <= shift_reg;
                            end case;
                            j := 2;
                        else
                            adder_run <= '1';
                            if(adder_ready = '1') then
                                adder_run <= '0';
                                intermed_prod <= adder_result(31 downto 0);
                                j := 0;
                                i := i + 1;
                            end if;
                        end if;
                    end if;
                when OUTPUT =>
                    ready <= '1';
                    mul_state <= PAUSE;
                when PAUSE =>
                    mul_state <= LOAD;
                end case;
            else
                mul_state <= LOAD;
            end if;
        end if;
    end process;
end multiplier_arch;
