-- Registrador para simular entradas e saidas da ULA bfloat16 no MIPS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registrador para 16 bits com controle de enable.
-- O registrador atualiza sua saída `q` com o valor da entrada `d` na borda de
-- subida do sinal `clk`, apenas quando `enable = '1'`.
entity bfloat16_register is
	port(
		clk, enable : in  std_logic;                -- clock (clk) e carga (enable)
		d           : in  std_logic_vector(15 downto 0);    -- dado de entrada
		q           : out std_logic_vector(15 downto 0)     -- dado armazenado
	);
end bfloat16_register;

architecture behavior OF bfloat16_register is
begin
    -- Se enable = '1', o valor de d deve ser atribuído a q.
    register_process: process(clk, enable)
        variable reg_value : std_logic_vector(15 downto 0);
    begin
        if enable = '1' and rising_edge(clk) then
            reg_value := d;
        end if;
        q <= reg_value;
    end process;
end architecture behavior;
