library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mul_tb is
end mul_tb;

architecture behv of mul_tb is
    signal a, b : STD_LOGIC_VECTOR(15 downto 0);
    signal y : STD_LOGIC_VECTOR(15 downto 0);

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

    dut: entity work.mul
    port map (
        A => a,
        B => b,
        S => y
    );
    
    proc: process
    begin
        -- Casos básicos de multiplicação
        a <= "0100000010100000"; b <= "0100000001000000"; wait for 10 ns; -- 5.0 * 3.0 = 15.0
        assert y = "0100000101110000" report "5.0 * 3.0 falhou. Valor esperado: '0100000101110000', valor retornado: " & slv_to_string(y);

        a <= "0100000010100000"; b <= "0000000000000000"; wait for 10 ns; -- 5.0 * 0.0 = 0.0
        assert y = "0000000000000000" report "5.0 * 0.0 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y);

        a <= "0100000010100000"; b <= "1011111110000000"; wait for 10 ns; -- 5.0 * -1.0 = -5.0
        assert y = "1100000010100000" report "5.0 * -1.0 falhou. Valor esperado: '1100000010100000', valor retornado: " & slv_to_string(y);

         a <= "1100000010100000"; b <= "1011111110000000"; wait for 10 ns; -- -5.0 * -1.0 = 5.0
        assert y = "0100000010100000" report "5.0 * -1.0 falhou. Valor esperado: '1100000010100000', valor retornado: " & slv_to_string(y);
        
        a <= "0111111110000001"; b <= "0111111110000001"; wait for 10 ns; -- NaN * NaN = NaN
        assert y(14 downto 7) = "11111111" and y(6 downto 0) /= "0000000" report "NaN * NaN falhou, esperado: expoente 11111111 e mantissa != 0, valor retornado: " & slv_to_string(y);

        a <= "0111111110000001"; b <= "0011111110000000"; wait for 10 ns; -- NaN * 1 = NaN
        assert y(14 downto 7) = "11111111" and y(6 downto 0) /= "0000000" report "NaN * 1 falhou, esperado: expoente 11111111 e mantissa != 0, valor retornado: " & slv_to_string(y);

        a <= "0111111110000001"; b <= "0111111110000001"; wait for 10 ns; -- NaN * NaN = NaN
        assert y(14 downto 7) = "11111111" and y(6 downto 0) /= "0000000" report "NaN * NaN falhou, esperado: expoente 11111111 e mantissa != 0, valor retornado: " & slv_to_string(y);

        a <= "0111111110000000"; b <= "0111111110000000"; wait for 10 ns; -- inf * inf = inf
        assert y = "0111111110000000" report "inf * inf falhou, esperado: 0111111110000000, valor retornado: " & slv_to_string(y);

        a <= "0111111110000000"; b <= "1111111110000000"; wait for 10 ns; -- inf * -inf = -inf
        assert y = "1111111110000000" report "inf * -inf falhou, esperado: 1111111110000001, valor retornado: " & slv_to_string(y);


        -- 1111111110000000 -inf
        -- 0111111110000000 +inf
    

        wait;
    end process;
end behv;
