library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mul is
    port (
        A, B : in  std_logic_vector(15 downto 0);
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

ARCHITECTURE structure OF mul IS
signal sinal_a, sinal_b, sinal_resultado: std_logic; -- Sinais para o sinal de A, B e resultado
signal expoente_a, expoente_b, expoente_resultado : unsigned(7 downto 0); -- Sinais para os expoentes de A, B e resultado
signal soma_expoentes: unsigned(8 downto 0); -- Sinal para o expoente do resultado, com 1 bit a mais para overflow
signal mantissa_a, mantissa_b, mantissa_resultado: unsigned(6 downto 0); -- Sinais para as mantissas de A, B e resultado
signal mantissa_mult : unsigned(17 downto 0);
signal fracao_a, fracao_b: unsigned(8 downto 0); -- Sinais para as frações de A, B
signal is_nan_a, is_nan_b, is_inf_a, is_inf_b, is_zero_a, is_zero_b: boolean; -- Sinais para NaN, Inf, Zero
BEGIN
    -- Extrair sinal, expoente e mantissa de A
    sinal_a <= A(15);
    expoente_a <= unsigned(A(14 downto 7));
    mantissa_a <= unsigned(A(6 downto 0));

    -- Extrair sinal, expoente e mantissa de B
    sinal_b <= B(15);
    expoente_b <= unsigned(B(14 downto 7));
    mantissa_b <= unsigned(B(6 downto 0));

     -- NaN: Expoente é 255 e mantissa não é zero
    is_nan_a <= (expoente_a = "11111111" and mantissa_a /= "0000000");
    is_nan_b <= (expoente_b = "11111111" and mantissa_b /= "0000000");

    -- Inf: Expoente é 255 e mantissa é zero
    is_inf_a <= (expoente_a = "11111111" and mantissa_a = "0000000");
    is_inf_b <= (expoente_b = "11111111" and mantissa_b = "0000000");

    -- Zero: Expoente é 0 e mantissa é zero
    is_zero_a <= (expoente_a = "00000000" and mantissa_a = "0000000");
    is_zero_b <= (expoente_b = "00000000" and mantissa_b = "0000000");


    PROCESS(A, B, sinal_a, sinal_b, expoente_a, expoente_b, mantissa_a, mantissa_b, fracao_a, fracao_b, mantissa_mult, mantissa_resultado, expoente_resultado, soma_expoentes, sinal_resultado) -- Todos os sinais e entradas
    BEGIN
        -- Valores padrão para evitar inferência de latches
        fracao_a <= (others => '0');
        fracao_b <= (others => '0');
        mantissa_mult <= (others => '0');
        mantissa_resultado <= (others => '0');
        expoente_resultado <= (others => '0');
        soma_expoentes <= (others => '0');
        sinal_resultado <= '0';


        --VERIFICAÇÕES PARA NAN, INF, ZERO
        if is_nan_a or is_nan_b then
            S <= "111111111" & "1000000"; -- NaN
        elsif is_inf_a and is_inf_b  then
            if sinal_a /= sinal_b then
                S <= "111111111" & "0000000"; -- Inf * - Inf = - Inf
            else
                S <= "111111111" & "0000000"; -- Inf * Inf = + Inf
            end if;
        elsif is_inf_a then
            S <= sinal_a & "11111111" & "0000000"; -- ±Inf
        elsif is_inf_b then
            S <= sinal_b & "11111111" & "0000000"; -- ±Inf
        elsif is_zero_a or is_zero_b then
            S <= "0000000000000000"; -- +0
        else
            -- Extrai a fração da mantissa de A
            if expoente_a = 0 then -- Valor subnormal ou zero
                fracao_a <= "00" & mantissa_a; 
            else -- Valor normalizado
                fracao_a <= "01" & mantissa_a; -- Adiciona o 1 implícito
            end if;

            -- Extrai a fração da mantissa de B
            if expoente_b = 0 then -- Valor subnormal ou zero
                fracao_b <= "00" & mantissa_b; 
            else -- Valor normalizado
                fracao_b <= "01" & mantissa_b; -- Adiciona o 1 implícito
            end if;

            -- Multiplicação das mantissas
            mantissa_mult <= fracao_a * fracao_b;

            -- Soma expoentes com ajuste
            soma_expoentes <= ('0' & expoente_a) + ('0' & expoente_b) - 127;

            -- Sinal do resultado
            sinal_resultado <= sinal_a xor sinal_b; -- Sinal do resultado é a XOR dos sinais de A e B

            -- Normalização do resultado (considerando subnormais também)
            if mantissa_mult(15) = '1' then
                -- Se o bit mais significativo da mantissa for 1, desloca para a direita
                mantissa_resultado <= mantissa_mult(14 downto 8);
                soma_expoentes <= soma_expoentes + 1;
            elsif mantissa_mult(14) = '1' then
                mantissa_resultado <= mantissa_mult(13 downto 7);
                expoente_resultado <= soma_expoentes(7 downto 0);
            elsif mantissa_mult(13) = '1' then
                mantissa_resultado <= mantissa_mult(12 downto 6);
                expoente_resultado <= soma_expoentes(7 downto 0) - 1;
            elsif mantissa_mult(12) = '1' then
                mantissa_resultado <= mantissa_mult(11 downto 5);
                expoente_resultado <= soma_expoentes(7 downto 0) - 2;
            elsif mantissa_mult(11) = '1' then
                mantissa_resultado <= mantissa_mult(10 downto 4);
                expoente_resultado <= soma_expoentes(7 downto 0) - 3;
            elsif mantissa_mult(10) = '1' then
                mantissa_resultado <= mantissa_mult(9 downto 3);
                expoente_resultado <= soma_expoentes(7 downto 0) - 4;
            elsif mantissa_mult(9) = '1' then
                mantissa_resultado <= mantissa_mult(8 downto 2);
                expoente_resultado <= soma_expoentes(7 downto 0) - 5;
            elsif mantissa_mult(8) = '1' then
                mantissa_resultado <= mantissa_mult(7 downto 1);
                expoente_resultado <= soma_expoentes(7 downto 0) - 6;
            else 
                mantissa_resultado <= mantissa_mult(6 downto 0);
                expoente_resultado <= soma_expoentes(7 downto 0) - 7;
            end if;
            
            S <= sinal_resultado & std_logic_vector(expoente_resultado) & std_logic_vector(mantissa_resultado); -- Concatena sinal, expoente e fração para formar o resultado final
        end if;
    END PROCESS;
END structure;