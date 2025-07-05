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
    begin
        for i in slv'range loop
            result(slv'left - i + 1) := std_ulogic'image(slv(i))(2); -- extrai o caractere '0' ou '1'
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
        -- 1.0 + 2.0 = 3.0
        a <= "0011111110000000"; b <= "0100000000000000"; op <= '0'; wait for 10 ns; -- 1.0 + 2.0 = 3.0
        assert y = "0100000001000000" report "1.0 + 2.0 falhou. Valor esperado: '0100000010000000', valor retornado: " & slv_to_string(y);

        a <= "0100000010100000"; b <= "0100000000000000"; op <= '0'; wait for 10 ns; -- 5.0 + 2.0 = 7.0
        assert y = "0100000011100000" report "5.0 + 2.0 falhou. Valor esperado: '0100000011100000', valor retornado: " & slv_to_string(y);
        
        -- Casos básicos de subtração
        -- Não suporta subtração de dois números negativos, nem sei se deveria
        a <= "0100000010100000"; b <= "0100000000000000"; op <= '1'; wait for 10 ns; -- 5.0 - 2.0 = 3.0
        assert y = "0100000001000000" report "5.0 - 2.0 falhou. Valor esperado: '0100000001000000', valor retornado: " & slv_to_string(y);

        a <= "0100000000000000"; b <= "0100000010100000"; op <= '1'; wait for 10 ns; -- 2.0 - 5.0 = -3.0
        assert y = "1100000001000000" report "2.0 - 5.0 falhou. Valor esperado: '1100000001000000', valor retornado: " & slv_to_string(y);

        -- Casos básicos de soma com fração
        a <= "0011111110100110"; b <= "0011111110100110"; op <= '0'; wait for 10 ns; -- 1.3 + 1.3 = 2.6
        assert y = "0100000000100110" report "1.3 + 1.3 falhou. Valor esperado: '0100000000100110', valor retornado: " & slv_to_string(y);

        a <= "0011111110100110"; b <= "0011111110100110"; op <= '1'; wait for 10 ns; -- 1.3 - 1.3 = 0.0
        assert y = "0000000000000000" report "1.3 - 1.3 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y);
        
        -- Casos com zero
        a <= "0000000000000000"; b <= "0100000001000000"; op <= '0'; wait for 10 ns; -- 0.0 + 3.0 = 3.0
        assert y = "0100000001000000" report "0.0 + 3.0 falhou:   " & slv_to_string(y);

        a <= "0000000000000000"; b <= "0000000000000000"; op <= '1'; wait for 10 ns; -- 3.0 - 3.0 = 0.0
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
        a <= "0000000001000000"; b <= "0000000001000000"; op <= '0'; wait for 10 ns; -- Subnormais
        assert y(14 downto 7) = "00000000" or y(14 downto 7) = "00000001" report "Subnormal falhou, expoente esperado: '00000000', expoente obtido: " & slv_to_string(y(14 downto 7));

        -- Finaliza simulação
        wait;
    end process;
end Behavioral;
