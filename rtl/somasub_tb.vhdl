library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity somasub_tb is
end somasub_tb;

architecture Behavioral of somasub_tb is
    signal a, b : STD_LOGIC_VECTOR(15 downto 0);
    signal y : STD_LOGIC_VECTOR(15 downto 0);
    signal op : STD_LOGIC; -- 0=Soma, 1=Subtrai

    -- Função para converter std_logic_vector em string
    function slv_to_string(slv: std_logic_vector) return string is
    variable result: string(1 to slv'length);
    variable c: string(1 to 3);
begin
    for i in slv'range loop
        c := std_ulogic'image(slv(i)); -- Ex: c = "'1'"
        result(i - slv'low + 1) := c(2); -- Extrai apenas o '1' sem aspas
    end loop;
    return result;
end function;


begin

    dut: entity work.somasub
    port map (
        A => a,
        B => b,
        op => op,
        S => y
    );
    
    proc: process
    begin
        -- Casos básicos de soma
        a <= "0011111110000000"; b <= "0100000000000000"; op <= '0'; wait for 10 ns; -- 1.0 + 2.0 = 3.0
        assert y = "0100000010000000" report "1.0 + 2.0 falhou:   " & slv_to_string(y);
        
        -- Casos básicos de subtração
        a <= "0100000100000000"; b <= "0100000000000000"; op <= '1'; wait for 10 ns; -- 5.0 - 2.0 = 3.0
        assert y = "0100000010000000" report "5.0 - 2.0 falhou:   " & slv_to_string(y);
        
        -- Casos com zero
        a <= "0000000000000000"; b <= "0100000010000000"; op <= '0'; wait for 10 ns; -- 0.0 + 3.0 = 3.0
        assert y = "0100000010000000" report "0.0 + 3.0 falhou:   " & slv_to_string(y);

        a <= "0100000010000000"; b <= "0100000010000000"; op <= '1'; wait for 10 ns; -- 3.0 - 3.0 = 0.0
        assert y = "0000000000000000" report "3.0 - 3.0 falhou:   " & slv_to_string(y);

        -- Casos com NaN (Not a Number)
        a <= "0111111111000000"; b <= "0100000000000000"; op <= '0'; wait for 10 ns; -- NaN + 2.0
        assert y(14 downto 7) = "11111111" and y(6 downto 0) /= "0000000" report "NaN + 2.0 falhou:   " & slv_to_string(y);

        -- Casos com infinito
        a <= "0111111110000000"; b <= "0100000000000000"; op <= '0'; wait for 10 ns; -- +Inf + 2.0
        assert y = "0111111110000000" report "+Inf + 2.0 falhou:   " & slv_to_string(y);

        a <= "0111111110000000"; b <= "0111111110000000"; op <= '1'; wait for 10 ns; -- +Inf - +Inf
        assert y(14 downto 7) = "11111111" and y(6 downto 0) /= "0000000" report "+Inf - +Inf falhou:   " & slv_to_string(y);

        -- Casos de overflow
        a <= "0111111100000000"; b <= "0111111100000000"; op <= '0'; wait for 10 ns; -- Overflow
        assert y = "0111111110000000" report "Overflow falhou:   " & slv_to_string(y);

        -- Casos de números desnormalizados
        a <= "0000000010000000"; b <= "0000000010000000"; op <= '0'; wait for 10 ns; -- Subnormais
        assert y(14 downto 7) = "00000000" or y(14 downto 7) = "00000001" report "Subnormal falhou:   " & slv_to_string(y);

        -- Finaliza simulação
        wait;
    end process;
end Behavioral;