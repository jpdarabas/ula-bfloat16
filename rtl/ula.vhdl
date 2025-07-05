library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port (
        A, B, C : in  std_logic_vector(15 downto 0); 
        OP   : in  std_logic_vector(2 downto 0); -- 8 Operações
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

ARCHITECTURE behaviour OF ula IS
    signal mul, ab_s, mac_s, saida : std_logic_vector(15 downto 0) := (others => '0'); -- Sinais intermediários
    signal ab_op, mac_op : std_logic := '0';

    -- Função para converter std_logic_vector em string
    function slv_to_string(slv: std_logic_vector) return string is
        variable result: string(1 to slv'length);
    begin
        for i in slv'range loop
            result(slv'left - i + 1) := std_ulogic'image(slv(i))(2); -- extrai o caractere '0' ou '1'
        end loop;
        return result;
    end function;

BEGIN
    ab_somasub: entity work.somasub
    port map (
        A => A,
        B => B,
        op => ab_op,
        S => ab_s
    );
    mulmul: entity work.mul
    port map (
        A => A,
        B => B,
        S => mul
    );
    mac_somasub: entity work.somasub
    port map (
        A => C,
        B => mul,
        op => mac_op,
        S => mac_s
    );

    S <= saida; -- Atribui o resultado da operação à saída S

    sinais: PROCESS(A, B, C, OP, ab_s, mul, mac_s)
    BEGIN
        -- Por padrão, definir valores para evitar 'U'
        ab_op <= '0';
        mac_op <= '0';
        saida <= (others => '0');

        CASE OP IS
            WHEN "000" => -- Soma (A + B)
                ab_op <= '0';
                saida <= ab_s;
            WHEN "001" => -- Subtração (A - B)
                ab_op <= '1';
                saida <= ab_s;
            WHEN "010" => -- AND bit a bit
                saida <= A and B;
            WHEN "011" => -- OR bit a bit
                saida <= A or B;
            WHEN "100" => -- A > B
                ab_op <= '1'; -- Configura como subtração (A - B)
                IF ab_s(15) = '1' THEN -- Se o resultado for negativo, A < B
                    saida <= "0000000000000000"; -- 0 em bfloat16 (A não é maior que B)
                ELSE
                    saida <= "0011111110000000"; -- 1 em bfloat16 (A é maior que B)
                END IF;
            WHEN "101" => -- A * B
                saida <= mul;
            WHEN "110" => -- ReLU
                if A(15) = '1' THEN -- Se for negativo
                    saida <= "0000000000000000"; -- Retorna 0 em bfloat16
                ELSE
                    saida <= A; -- Retorna A se for positivo
                END IF;
            WHEN "111" => -- C + (A*B)
                mac_op <= '0';
                saida <= mac_s;
            WHEN OTHERS =>
                saida <= (others => '0'); -- Retorna zero se a operação não for reconhecida
        END CASE;

        
        -- Debugging: report
        -- report "ULA - A: " & slv_to_string(A) & " B: " & slv_to_string(B) & " C: " & slv_to_string(C) & " OP: " & slv_to_string(OP) severity note;
        -- report "AB_op: " & std_logic'image(ab_op) severity note;
        -- report "AB_s: " & slv_to_string(ab_s) severity note;
        -- report "MAC_op: " & std_logic'image(mac_op) severity note;
        -- report "MAC_s: " & slv_to_string(mac_s) severity note;
        -- report "S: " & slv_to_string(saida) severity note;
    END PROCESS sinais;
END behaviour;
