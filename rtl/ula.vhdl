library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ula is
    port (
        A, B, C : in  std_logic_vector(15 downto 0);  -- N bits
        OP   : in  std_logic_vector(2 downto 0); -- 8 OPerações
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

ARCHITECTURE behaviour OF ula IS
BEGIN
    add <= A + B; -- ALTERAR PARA BFLOAT16
    sub <= A - B; -- ALTERAR PARA BFLOAT16
    mul <= A * B; -- ALTERAR PARA BFLOAT16
    mac <= C + mul; -- ALTERAR PARA BFLOAT16

    PROCESS(A, B, C, OP)
    BEGIN
        CASE OP IS
            WHEN "000" => -- Soma (A + B)
                S <= add;
            WHEN "001" => -- Subtração (A - B)
                S <= sub;
            WHEN "010" => -- AND bit a bit
        
            WHEN  "011" => -- OR bit a bit

            WHEN "100" => -- A > B
            -- (A > B) ? 1 : 0 no formato bfloat16
                IF sub(0) = '1' THEN
                    S <= "0000000000000000"; -- S <= 0 bfloat16
                ELSE
                    -- S <= 1 bfloat16
                END IF;
            WHEN "101" => -- A * B
                S <= mul;
            WHEN "110" => -- ReLU
            -- ReLU(A) = max(0, A) no formato bfloat16
                if A(15) == '1' THEN
                -- S <= 0 BFLOAT
                ELSE
                    S <= A; -- Retorna A se for positivo
                END IF;
            WHEN "111" => -- C + (A*B)
                S <= mac;
        END CASE;

    END PROCESS;
END behaviour;