-- Testbench toplevel (MESMOS TESTES DA ULA)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity topo_tb is
end topo_tb;

architecture Behavioral of topo_tb is
    signal a, b, c, y : std_logic_vector(15 downto 0) := (others => '0');
    signal op         : std_logic_vector(2 downto 0) := "000";
    signal clk        : std_logic := '0';
    signal enable     : std_logic := '1';

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
    -- Instância da entidade topo
    dut: entity work.topo
    port map (
        clk    => clk,
        enable => enable,
        A_in   => a,
        B_in   => b,
        C_in   => c,
        OP     => op,
        S_out  => y
    );
    
    -- Processo para gerar o clock (50 MHz, período de 20 ns)
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;
    
    -- Processo de estímulo para os testes
    stim_process: process
    begin
        -- Inicialização
        a <= "0000000000000000";
        b <= "0000000000000000";
        c <= "0000000000000000";
        op <= "000";
        wait for 100 ns; -- Espera inicial maior para estabilizar o sistema

        -- Casos básicos de soma
        -- 1.0 + 2.0 = 3.0
        a <= "0011111110000000"; b <= "0100000000000000"; c <= "0000000000000000"; op <= "000"; wait for 60 ns; -- 1.0 + 2.0 = 3.0
        assert y = "0100000001000000" report "1.0 + 2.0 falhou. Valor esperado: '0100000001000000', valor retornado: " & slv_to_string(y) severity error;

        a <= "0100000010100000"; b <= "0100000000000000"; c <= "0000000000000000"; op <= "000"; wait for 60 ns; -- 5.0 + 2.0 = 7.0
        assert y = "0100000011100000" report "5.0 + 2.0 falhou. Valor esperado: '0100000011100000', valor retornado: " & slv_to_string(y) severity error;
        
        -- Casos básicos de subtração
        a <= "0100000010100000"; b <= "0100000000000000"; c <= "0000000000000000"; op <= "001"; wait for 60 ns; -- 5.0 - 2.0 = 3.0
        assert y = "0100000001000000" report "5.0 - 2.0 falhou. Valor esperado: '0100000001000000', valor retornado: " & slv_to_string(y) severity error;

        a <= "0100000000000000"; b <= "0100000010100000"; c <= "0000000000000000"; op <= "001"; wait for 60 ns; -- 2.0 - 5.0 = -3.0
        assert y = "1100000001000000" report "2.0 - 5.0 falhou. Valor esperado: '1100000001000000', valor retornado: " & slv_to_string(y) severity error;

        -- AND bit a bit
        a <= "0100000000000000"; b <= "0100000001000000"; c <= "0000000000000000"; op <= "010"; wait for 60 ns;
        assert y = "0100000000000000" report "0100000000000000 AND 0100000001000000 falhou. Valor esperado: '0100000000000000', valor retornado: " & slv_to_string(y) severity error;

        -- OR bit a bit
        a <= "0100000000000000"; b <= "0010000001000000"; c <= "0000000000000000"; op <= "011"; wait for 60 ns;
        assert y = "0110000001000000" report "0100000000000000 OR 0010000001000000 falhou. Valor esperado: '0110000001000000', valor retornado: " & slv_to_string(y) severity error;

        -- A > B
        a <= "0100000000000000"; b <= "0010000001000000"; c <= "0000000000000000"; op <= "100"; wait for 60 ns;
        assert y = "0011111110000000" report "0100000000000000 > 0010000001000000 falhou. Valor esperado: '0011111110000000', valor retornado: " & slv_to_string(y) severity error;

        a <= "0010000001000000"; b <= "0100000000000000"; c <= "0000000000000000"; op <= "100"; wait for 60 ns;
        assert y = "0000000000000000" report "0010000001000000 > 0100000000000000 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y) severity error;

        -- A * B
        a <= "0100000010100000"; b <= "0100000001000000"; c <= "0000000000000000"; op <= "101"; wait for 60 ns;
        assert y = "0100000101110000" report "5.0 * 3.0 falhou. Valor esperado: '0100000101110000', valor retornado: " & slv_to_string(y) severity error;

        a <= "0100000010100000"; b <= "0000000000000000"; c <= "0000000000000000"; op <= "101"; wait for 60 ns;
        assert y = "0000000000000000" report "5.0 * 0.0 falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y) severity error;

        -- ReLU(A)
        a <= "0010000001000000"; b <= "0000000000000000"; c <= "0000000000000000"; op <= "110"; wait for 60 ns;
        assert y = "0010000001000000" report "ReLU(0010000001000000) falhou. Valor esperado: '0010000001000000', valor retornado: " & slv_to_string(y) severity error;

        a <= "1010000001000000"; b <= "0000000000000000"; c <= "0000000000000000"; op <= "110"; wait for 60 ns;
        assert y = "0000000000000000" report "ReLU(1010000001000000) falhou. Valor esperado: '0000000000000000', valor retornado: " & slv_to_string(y) severity error;

        -- C + A*B
        a <= "0100000010100000"; b <= "0000000000000000"; c <= "0100000000000000"; op <= "111"; wait for 60 ns;
        assert y = "0100000000000000" report "2.0 + 5.0 * 0.0 falhou. Valor esperado: '0100000000000000', valor retornado: " & slv_to_string(y) severity error;
        
        a <= "0100000010100000"; b <= "0011111110000000"; c <= "0100000000000000"; op <= "111"; wait for 60 ns;
        assert y = "0100000011100000" report "2.0 + 5.0 * 1.0 falhou. Valor esperado: '0100000011100000', valor retornado: " & slv_to_string(y) severity error;

        -- Finaliza simulação
        wait;
    end process;
end Behavioral;