# ULA com funções adicionais usando bfloat16

## Usar GHDL para simulação:
[Link para baixar ghdl](https://github.com/ghdl/ghdl/releases)
* Extrair o zip em uma pasta
* Adicionar ao path:
    * Clique com botão direito em "Este Computador" → Propriedades
    * Vá em "Configurações avançadas do sistema" → Variáveis de ambiente
    * Em "Path", clique em "Editar"
    * Adicione o caminho da pasta onde você extraiu o GHDL (ex: C:\ghdl\bin)
    * Salve tudo
* Verificar se está funcionando:
```bash
ghdl --version
```

# Estrutura do bfloat16 (16 bits):
Bits | Significado
-- | --
1 bit | Sinal (S)
8 bits | Expoente (E)
7 bits | Mantissa (M)

* Fração = $M[6] \times 2^{-1} + M[5] \times 2^{-2} + M[4] \times 2^{-3} + M[3] \times 2^{-4} + M[2] \times 2^{-5} + M[1] \times 2^{-7} + M[0] \times 2^{-8}$

# Fórmula geral para números normais (não subnormais, nem infinitos, nem NaN):
$$ Valor = (-1)^{S} \times (1 + fração) \times 2^{E-bias}$$

* $bias = 127$ 

## Exemplo: 0 10000000 0000000
* Sinal = 0  $\rightarrow$ positivo
* Expoente = 10000000 = 128
* Mantissa = 0000000 = 0

$$ Valor = (-1)^0 \times (1 + 0) \times 2^{128-127} = 1 \times 1 \times 2^1 = 2  $$

## Exemplo: 1 01111110 1000000
* Sinal = 1 $\rightarrow$ negativo
* Expoente = 01111110 = 126
* Mantissa = 1000000 = $$1 \times 2^{-1} = 0.5$$

$$ Valor = (-1)^1 \times (1 + 0.5) \times 2^{126-127} = -1 \times 1.5 \times 2^{-1} = -1.5 \times 0.5 =-0.75 $$

# Casos especiais:

Expoente (E) | Mantissa (M) | Sinal (S) | Significado | Exemplo em bits (S E M)
-- | -- | -- | -- | --
00000000 | 0000000 | 0 ou 1 | Zero (positivo ou negativo) | 0 00000000 0000000 → +0.01 00000000 0000000 → -0.0
00000000 | ≠ 0000000 | 0 ou 1 | Subnormal (denormal) | 0 00000000 0000001 → menor positivo
00000001 → 11111110 | qualquer valor | 0 ou 1 | Número normal (com 1 implícito) | 0 01111111 0000000 → +1.0
11111111 | 0000000 | 0 ou 1 | Infinito (+∞ ou -∞) | 0 11111111 0000000 → +∞1 11111111 0000000 → -∞
11111111 | ≠ 0000000 | 0 ou 1 | NaN (Not a Number) | 0 11111111 1000000 → NaN

* NaN $\pm$ (qualquer) = NaN
* Infinito + (qualquer) = infinito
* - Infinito + (qualquer) = - infinito
* Infinito - infinito = NaN


# Fórmula para subnormais:

$$ Valor = (-1)^S \times fração \times 2^{-126} $$

## Exemplo: 0 00000000 0000001
* Sinal = 0 $\rightarrow$ positivo
* Expoente = 00000000 = 0 $\rightarrow$ Mantissa $\neq$ 0 $\rightarrow$ Subnormal
* Mantissa = 0000001 $\rightarrow$ Fração = $2^{-7}$

$$ Valor = (-1)^0 \times 2^{-7} \times 2^{-126}  = 2^{-133}$$
