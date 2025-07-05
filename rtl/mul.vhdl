library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul is
    port (
        A, B : in  std_logic_vector(15 downto 0);
        S    : out std_logic_vector(15 downto 0)
    );
end entity;

architecture structure of mul is
    -- Sinais de extração dos operandos
    signal sinal_a, sinal_b      : std_logic;
    signal expoente_a, expoente_b: unsigned(7 downto 0);
    signal mantissa_a, mantissa_b: unsigned(6 downto 0);

    -- Sinais para checagem de casos especiais
    signal is_nan_a, is_nan_b, is_inf_a, is_inf_b, is_zero_a, is_zero_b: boolean;

begin
    -- =================================================================
    -- PARTE 1: Extração e Análise dos Operandos (Lógica Concorrente)
    -- =================================================================

    sinal_a    <= A(15);
    expoente_a <= unsigned(A(14 downto 7));
    mantissa_a <= unsigned(A(6 downto 0));

    sinal_b    <= B(15);
    expoente_b <= unsigned(B(14 downto 7));
    mantissa_b <= unsigned(B(6 downto 0));

    is_nan_a  <= true when (expoente_a = "11111111" and mantissa_a /= 0) else false;
    is_nan_b  <= true when (expoente_b = "11111111" and mantissa_b /= 0) else false;
    is_inf_a  <= true when (expoente_a = "11111111" and mantissa_a = 0)  else false;
    is_inf_b  <= true when (expoente_b = "11111111" and mantissa_b = 0)  else false;
    is_zero_a <= true when (expoente_a = "00000000" and mantissa_a = 0)  else false;
    is_zero_b <= true when (expoente_b = "00000000" and mantissa_b = 0)  else false;


    -- =================================================================
    -- PARTE 2: Lógica de Multiplicação (Processo Combinacional)
    -- =================================================================
    calculation_proc: process(sinal_a, sinal_b, expoente_a, expoente_b, mantissa_a, mantissa_b, is_nan_a, is_nan_b, is_inf_a, is_inf_b, is_zero_a, is_zero_b)
        variable sinal_resultado     : std_logic;
        variable fracao_a, fracao_b  : unsigned(7 downto 0);
        variable expoente_a_int, expoente_b_int, soma_expoentes_int, expoente_resultado_int : integer;
        variable fracao_mult         : unsigned(15 downto 0);
        variable mantissa_resultado_var : unsigned(6 downto 0);
        variable expoente_resultado_vec : unsigned(7 downto 0);
        
    begin
        -- Cálculo unificado do sinal
        sinal_resultado := sinal_a xor sinal_b;

        -- ===========================================================================
        --           *** INÍCIO DA SEÇÃO ALTERADA ***
        -- Lógica hierárquica para tratar casos especiais
        -- ===========================================================================

        -- NÍVEL 1: A entrada já é NaN? (Prioridade máxima)
        if is_nan_a or is_nan_b then
            -- Se qualquer entrada for NaN, o resultado é sempre NaN.
            S <= "0111111111000000"; -- Retorna um QNaN (Quiet NaN) padrão

        else
            -- NÍVEL 2: A operação resulta em uma indeterminação? (Segunda prioridade)
            if (is_zero_a and is_inf_b) or (is_inf_a and is_zero_b) then
                -- A operação 0 x Infinito é uma indeterminação, resultando em NaN.
                S <= "0111111111000000"; -- Retorna um QNaN (Quiet NaN) padrão
            
            else
                -- NÍVEL 3: A operação envolve Infinito ou Zero (casos definidos)?
                if is_inf_a or is_inf_b then
                    -- Se uma entrada é Infinita (e a outra não é Zero), o resultado é Infinito.
                    -- O sinal correto já foi calculado.
                    S <= sinal_resultado & "11111111" & "0000000"; -- ±Infinito

                elsif is_zero_a or is_zero_b then
                    -- Se uma entrada é Zero (e a outra não é Infinita), o resultado é Zero.
                    -- O sinal correto já foi calculado.
                    S <= sinal_resultado & "00000000" & "0000000"; -- ±Zero
                
                else
                    -- =======================================================================
                    -- NÍVEL 4: Caminho para Números Normais/Subnormais (nenhum caso especial)
                    -- =======================================================================

                    -- 1. Reconstruir a fração (adicionar bit oculto)
                    if expoente_a = 0 then
                        fracao_a := '0' & mantissa_a;
                        expoente_a_int := 1;
                    else
                        fracao_a := '1' & mantissa_a;
                        expoente_a_int := to_integer(expoente_a);
                    end if;

                    if expoente_b = 0 then
                        fracao_b := '0' & mantissa_b;
                        expoente_b_int := 1;
                    else
                        fracao_b := '1' & mantissa_b;
                        expoente_b_int := to_integer(expoente_b);
                    end if;

                    -- 2. Multiplicar as frações
                    fracao_mult := fracao_a * fracao_b;

                    -- 3. Somar os expoentes
                    soma_expoentes_int := expoente_a_int + expoente_b_int - 127;

                    -- 4. Normalização do Resultado
                    if fracao_mult(15) = '1' then
                        mantissa_resultado_var := fracao_mult(14 downto 8);
                        expoente_resultado_int := soma_expoentes_int + 1;
                    else
                        mantissa_resultado_var := fracao_mult(13 downto 7);
                        expoente_resultado_int := soma_expoentes_int;
                    end if;
                    
                    -- 5. Tratar Underflow/Overflow do expoente e montar o resultado
                    if expoente_resultado_int >= 255 then
                        S <= sinal_resultado & "11111111" & "0000000"; -- Overflow -> Infinito
                    elsif expoente_resultado_int <= 0 then
                        S <= sinal_resultado & "00000000" & "0000000"; -- Underflow -> Zero
                    else
                        expoente_resultado_vec := to_unsigned(expoente_resultado_int, 8);
                        S <= sinal_resultado & std_logic_vector(expoente_resultado_vec) & std_logic_vector(mantissa_resultado_var);
                    end if;
                end if;
            end if;
        end if;
        -- ===========================================================================
        --           *** FIM DA SEÇÃO ALTERADA ***
        -- ===========================================================================

    end process calculation_proc;

end architecture structure;
