# yad-ssh-manager
Uma interface gráfica simples e prática para gerenciar e conectar a servidores SSH utilizando **Bash + YAD**.

Este script fornece uma interface visual para:

* Listar conexões SSH salvas
* Adicionar novos servidores
* Conectar via terminal
* Gerenciar o arquivo `~/.ssh/config` 


## Requisitos

* `bash`
* `yad`
* `ssh`
* Um terminal compatível:

  * `konsole` (padrão no script)
  * ou adapte para `xfce4-terminal`, `gnome-terminal`, `xterm`


## Funcionalidades

### Listar conexões

* Mostra todos os hosts definidos no `~/.ssh/config`
* Exibe:

  * Apelido (alias)
  * Endereço (HostName)
  * Usuário
  * Porta

### Adicionar nova conexão

* Interface gráfica para inserir:

  * Alias
  * Host/IP
  * Usuário
  * Porta
* Evita duplicação de aliases

### Conectar

* Clique duplo ou botão **Conectar**
* Abre um terminal executando:

  ```bash
  ssh alias
  ```

## Como usar

1. Dê permissão de execução:

   ```bash
   chmod +x ssh_manager_visual.sh
   ```

2. Execute:

   ```bash
   ./ssh_manager_visual.sh
   ```


