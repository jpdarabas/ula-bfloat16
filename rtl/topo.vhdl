library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity topo is
  port(
    clk    : in  std_logic;
    enable : in  std_logic;
    A_in   : in  std_logic_vector(15 downto 0);
    B_in   : in  std_logic_vector(15 downto 0);
    C_in   : in  std_logic_vector(15 downto 0);
    OP     : in  std_logic_vector(2 downto 0); -- Add, Sub, And, Or, GT, Mul, ReLU, MAC
    S_out  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of topo is
  signal A_reg, B_reg, C_reg: std_logic_vector(15 downto 0);
  signal S_reg: std_logic_vector(15 downto 0);
begin

  -- registrador A
  Areg: entity work.bfloat16_register
    port map(clk => clk, enable => enable, d => A_in, q => A_reg);

  -- registrador B
  Breg: entity work.bfloat16_register
    port map(clk => clk, enable => enable, d => B_in, q => B_reg);

  -- registrador C
  Creg: entity work.bfloat16_register
    port map(clk => clk, enable => enable, d => C_in, q => C_reg);

  -- ULA pura (combinacional)
  ula: entity work.ula
    port map(
      A  => A_reg,
      B  => B_reg,
      C  => C_reg,
      OP => OP,
      S  => S_reg
    );

  -- registrador saída S
  Sreg: entity work.bfloat16_register
    port map(clk => clk, enable => enable, d => S_reg, q => S_out);

end architecture;