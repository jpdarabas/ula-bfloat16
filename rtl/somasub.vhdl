library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity somasub is
    port (
        A, B : in  std_logic_vector(N-1 downto 0);  -- N bits
        op   : in  std_logic;                        -- 0=Soma, 1=Subtrai
        S    : out std_logic_vector(N-1 downto 0)
    );
end entity;

ARCHITECTURE behaviour OF somasub IS
BEGIN
    PROCESS(A, B, op)
    BEGIN
        S <= A + B when op = '0' else A - B; -- alterar para bfloat16
    END PROCESS;
END behaviour;