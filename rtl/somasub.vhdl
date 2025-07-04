library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity somasub is
    port (
        A, B : in  std_logic_vector(15 downto 0);
        op   : in  std_logic; -- 0=Soma, 1=Subtrai
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

ARCHITECTURE behaviour OF somasub IS
signal sinal_a, sinal_b, sinal_resultado : std_logic; -- Sinais para o sinal de A, B e resultado
signal expoente_a, expoente_b, expoente_max, expoente_resultado : unsigned(7 downto 0); -- Sinais para os expoentes de A, B e resultado
signal mantissa_a, mantissa_b : unsigned(6 downto 0); -- Sinais para as mantissas de A, B
signal fracao_a, fracao_b, fracao_a_deslocada, fracao_b_deslocada : unsigned(8 downto 0); -- Sinais para as frações de A, B e suas versões deslocadas
signal fracao_soma: signed(9 downto 0); -- Sinal para a fração da soma, com um bit extra para o carry
signal fracao_resultado : unsigned(6 downto 0); -- Sinal para a fração do resultado, com 7 bits
signal is_nan_a, is_nan_b, is_inf_a, is_inf_b, is_zero_a, is_zero_b: boolean; -- Sinais para NaN, Inf, Zero

BEGIN
    -- Extrair sinal, expoente e mantissa de A
    sinal_a <= A(15);
    expoente_a <= unsigned(A(14 downto 7));
    mantissa_a <= unsigned(A(6 downto 0));

    -- Extrair sinal, expoente e mantissa de B
    sinal_b <= B(15) xor op; -- Inverte o sinal de B se op for 1
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

    PROCESS(A, B, op, is_nan_a, is_nan_b, is_inf_a, is_inf_b, sinal_a, sinal_b, expoente_a, expoente_b, mantissa_a, mantissa_b, fracao_a, fracao_b, fracao_a_deslocada, fracao_b_deslocada, fracao_soma, sinal_resultado, expoente_max, expoente_resultado, fracao_resultado, is_zero_a, is_zero_b) -- Todos os sinais e entradas
    BEGIN
        -- Valores padrão para evitar inferência de latches
        fracao_a <= (others => '0');
        fracao_b <= (others => '0');
        fracao_a_deslocada <= (others => '0');
        fracao_b_deslocada <= (others => '0');
        fracao_soma <= (others => '0');
        fracao_resultado <= (others => '0');
        expoente_max <= (others => '0');
        expoente_resultado <= (others => '0');
        sinal_resultado <= '0';


        -- VERIFICAÇÕES PARA NAN, INF, ZERO E SUBNORMAL
        if is_nan_a or is_nan_b then
            S <= "111111111" & "1000000"; -- NaN
        elsif is_inf_a and is_inf_b and (sinal_a /= sinal_b) then
            S <= "111111111" & "1000000"; -- Inf - Inf = NaN
        elsif is_inf_a then
            S <= sinal_a & "11111111" & "0000000"; -- ±Inf
        elsif is_inf_b then
            S <= sinal_b & "11111111" & "0000000"; -- ±Inf
        elsif is_zero_a and is_zero_b then
            S <= "0000000000000000"; -- +0
        elsif is_zero_a then
            S <= sinal_b & std_logic_vector(expoente_b) & std_logic_vector(mantissa_b);
        elsif is_zero_b then
            S <= sinal_a & std_logic_vector(expoente_a) & std_logic_vector(mantissa_a);
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

            -- Alinhando expoentes
            if expoente_a > expoente_b then
                expoente_max <= expoente_a;
                fracao_a_deslocada <= fracao_a; -- Mantém a fração de A
                fracao_b_deslocada <= shift_right(fracao_b, to_integer(expoente_a - expoente_b)); -- Desloca a mantissa de B equivalente à diferença de expoentes
            else
                expoente_max <= expoente_b;
                fracao_a_deslocada <= shift_right(fracao_a, to_integer(expoente_b - expoente_a)); -- Desloca a mantissa de A equivalente à diferença de expoentes
                fracao_b_deslocada <= fracao_b; -- Mantém a fração de B
            end if;

            -- Soma ou subtração das frações
            if sinal_a = sinal_b then -- Sinais iguais, soma
                fracao_soma <= signed('0' & fracao_a_deslocada) + signed('0' & fracao_b_deslocada); -- Soma as frações se os sinais forem iguais
                sinal_resultado <= sinal_a; -- Mantém o sinal do resultado igual ao de A (ou B, já que são iguais)
            else -- Sinais diferentes, subtração do maior pelo menor
                if fracao_a_deslocada >= fracao_b_deslocada then
                    fracao_soma <= signed('0' & fracao_a_deslocada) - signed('0' & fracao_b_deslocada); -- Subtrai as frações se A for maior ou igual a B
                    sinal_resultado <= sinal_a; --  Sinal do resultado igual ao de A
                else
                    fracao_soma <= signed('0' & fracao_b_deslocada) - signed('0' & fracao_a_deslocada); -- Subtrai as frações se B for maior que A
                    sinal_resultado <=  sinal_b; -- Sinal do resultado igual ao de B
                end if;
            end if;

            -- Normalização do resultado
            if fracao_soma(9) = '1' then -- Se o bit mais significativo da fração for 1, já está normalizado
                fracao_resultado <= unsigned(fracao_soma(8 downto 2)); -- Mantém os 7 bits significativos
                expoente_resultado <= expoente_max + 1; -- Incrementa o expoente
            elsif fracao_soma(8) = '1' then -- Se o segundo bit mais significativo for 1, desloca a fração
                fracao_resultado <= unsigned(fracao_soma(7 downto 1)); -- Desloca a fração para normalizar
                expoente_resultado <= expoente_max; -- Mantém o expoente máximo
            else -- Se ambos os bits mais significativos forem 0, decrementa o expoente
                fracao_resultado <= unsigned(fracao_soma(6 downto 0)); -- Mantém os 7 bits significativos
                expoente_resultado <= expoente_max - 1; -- Decrementa o expoente
            end if;

            -- Resultado final
            S <= sinal_resultado & std_logic_vector(expoente_resultado) & std_logic_vector(fracao_resultado); -- Concatena sinal, expoente e fração para formar o resultado final
        end if;
    END PROCESS;
END behaviour;