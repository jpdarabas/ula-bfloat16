library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mul is
    port (
        A, B : in  std_logic_vector(N-1 downto 0);  -- N bits
        S    : out std_logic_vector(N-1 downto 0);
    );
end entity;

ARCHITECTURE structure OF mul IS
BEGIN
    PROCESS(A, B, op)
    BEGIN
        S <= std_logic_vector(unsigned(A) * unsigned(B));  -- Alterar para bfloat16
    END PROCESS;
END structure;