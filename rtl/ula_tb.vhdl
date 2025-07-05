library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ula_tb is
end ula_tb;

architecture Behavioral of ula_tb is
    signal a, b, c, y: std_logic_vector(15 downto 0) := (others => '0');
    signal op: std_logic_vector(2 downto 0) := "000";

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

    dut: entity work.ula
    port map (
        A => a,
        B => b,
        C => c,
        OP => op,
        S => y
    );
    
    proc: process
    begin
        -- Casos básicos de soma
        -- 1.0 + 2.0 = 3.0
        a <= "0011111110000000"; b <= "0100000000000000"; c<= "0000000000000000"; op <= "000"; wait for 10 ns; -- 1.0 + 2.0 = 3.0
        assert y = "0100000001000000" report "1.0 + 2.0 falhou. Valor esperado: '0100000010000000', valor retornado: " & slv_to_string(y);

        a <= "0100000010100000"; b <= "0100000000000000"; c<= "0000000000000000"; op <= "000"; wait for 10 ns; -- 5.0 + 2.0 = 7.0
        assert y = "0100000011100000" report "5.0 + 2.0 falhou. Valor esperado: '0100000011100000', valor retornado: " & slv_to_string(y);
        
        -- Casos básicos de subtração
        -- Não suporta subtração de dois números negativos, nem sei se deveria
        a <= "0100000010100000"; b <= "0100000000000000"; c<= "0000000000000000"; op <= "001"; wait for 10 ns; -- 5.0 - 2.0 = 3.0
        assert y = "0100000001000000" report "5.0 - 2.0 falhou. Valor esperado: '0100000001000000', valor retornado: " & slv_to_string(y);

        a <= "0100000000000000"; b <= "0100000010100000"; c<= "0000000000000000"; op <= "001"; wait for 10 ns; -- 2.0 - 5.0 = -3.0
        assert y = "1100000001000000" report "2.0 - 5.0 falhou. Valor esperado: '1100000001000000', valor retornado: " & slv_to_string(y);

        -- And bit a bit
        a <= "0100000000000000"; b <= "0100000001000000";  c<= "0000000000000000"; op <= "010"; wait for 10 ns;
        assert y = "0100000000000000" report "0100000000000000 AND 0100000001000000 falhou. Valor esperado: '0100000000000000', valor retornado: " & slv_to_string(y);

        -- Or bit a bit
        a <= "0100000000000000"; b <= "0010000001000000";  c<= "0000000000000000"; op <= "011"; wait for 10 ns;
        assert y = "0110000001000000" report "0100000000000000 OR 0010000001000000 falhou. Valor esperado: '0110000001000000', valor retornado: " & slv_to_string(y);

        --  A > B 0011111110000000
         a <= "0100000000000000"; b <= "0010000001000000";  c<= "0000000000000000"; op <= "100"; wait for 10 ns;
        assert y = "0011111110000000" report "0100000000000000 > 0010000001000000 falhou. Valor esperado: '0011111110000000', valor retornado: " & slv_to_string(y);

        a <= "0010000001000000"; b <= "0100000000000000";  c<= "0000000000000000"; op <= "100"; wait for 10 ns;
        assert y = "0000000000000000" report "0010000001000000 > 0100000000000000 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y);

        -- A*B
        a <= "0100000010100000"; b <= "0100000001000000";  c<= "0000000000000000"; op <= "101"; wait for 10 ns;
        assert y = "0100000101110000" report "5.0 * 3.0 falhou. Valor esperado: '0100000101110000', valor retornado: " & slv_to_string(y);

         a <= "0100000010100000"; b <= "0000000000000000";  c<= "0000000000000000"; op <= "101"; wait for 10 ns;
        assert y = "0000000000000000" report "5.0 * 0.0 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y);


        -- ReLU(A)
        a <= "0010000001000000"; b <= "0000000000000000";  c<= "0000000000000000"; op <= "110"; wait for 10 ns;
        assert y = "0010000001000000" report "ReLU(0010000001000000) falhou. Valor esperado: '0010000001000000', valor retornado: " & slv_to_string(y);

        a <= "1010000001000000"; b <= "0000000000000000";  c<= "0000000000000000"; op <= "110"; wait for 10 ns;
        assert y = "0000000000000000" report "ReLU(1010000001000000) falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y);

        -- C + A*B

        a <= "0100000010100000"; b <= "0000000000000000";  c<= "0100000000000000"; op <= "111"; wait for 10 ns;
        assert y = "0100000000000000" report "2.0 + 5.0 * 0.0 falhou. Valor esperado: '0100000000000000', valor retornado: " & slv_to_string(y);
        

        a <= "0100000010100000"; b <= "0011111110000000";  c<= "0100000000000000"; op <= "111"; wait for 10 ns;
        assert y = "0100000011100000" report "2.0 + 5.0 * 1.0 falhou. Valor esperado: '0100000011100000', valor retornado: " & slv_to_string(y);

        -- Finaliza simulação
        wait;
    end process;
end Behavioral;
