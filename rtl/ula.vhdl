library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ula is
    port (
        A, B, C : in  std_logic_vector(15 downto 0); 
        OP   : in  std_logic_vector(2 downto 0); -- 8 OPerações
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

ARCHITECTURE behaviour OF ula IS
signal add, sub, mul, mac : std_logic_vector(15 downto 0); -- Sinais intermediários para operações
BEGIN
    addsomasub: entity work.somasub
    port map (
        A => A,
        B => B,
        op => '0',
        S => add
    );
    subsomasub: entity work.somasub
    port map (
        A => A,
        B => B,
        op => '1',
        S => sub
    );
    mulmul: entity work.mul
    port map (
        A => A,
        B => B,
        S => mul
    );
    macsomasub: entity work.somasub
    port map (
        A => C,
        B => mul, -- Multiplicação de A e B
        op => '0', -- Soma para MAC
        S => mac
    );

    PROCESS(A, B, C, OP)
    BEGIN
        CASE OP IS
            WHEN "000" => -- Soma (A + B)
                S <= add;
            WHEN "001" => -- Subtração (A - B)
                S <= sub;
            WHEN "010" => -- AND bit a bit
                S <= A and B; -- Operação AND bit a bit
            WHEN "011" => -- OR bit a bit
                S <= A or B; -- Operação OR bit a bit
            WHEN  "011" => -- OR bit a bit

            WHEN "100" => -- A > B
            -- (A > B) ? 1 : 0 no formato bfloat16
                IF sub(0) = '1' THEN
                    S <= "0000000000000000"; -- S <= 0 bfloat16
                ELSE
                    S <= "0011111110000000"; -- S <= 1 bfloat16
                END IF;
            WHEN "101" => -- A * B
                S <= mul;
            WHEN "110" => -- ReLU
            -- ReLU(A) = max(0, A) no formato bfloat16
                if A(15) = '1' THEN
                    S <= "0000000000000000"; -- S <= 0 bfloat16
                ELSE
                    S <= A; -- Retorna A se for positivo
                END IF;
            WHEN "111" => -- C + (A*B)
                S <= mac;
        END CASE;

    END PROCESS;
END behaviour;