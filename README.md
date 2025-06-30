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