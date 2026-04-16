#!/bin/bash

# ==============================================================================
# Script: SSH Manager Visual & Interativo
# Descrição: Interface gráfica para gerenciar e conectar a servidores SSH.
# Requisitos: yad, ssh, terminal (xfce4-terminal, gnome-terminal ou xterm)
# ==============================================================================

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

ICON_SERVER="network-server"
ICON_ADD="list-add"
ICON_CONNECT="network-transmit-receive"
ICON_EXIT="application-exit"

setup_env() {
    [[ ! -d "$SSH_DIR" ]] && mkdir -p "$SSH_DIR" && chmod 700 "$SSH_DIR"
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
}

conectar() {
    local target="$1"
    local cmd="ssh $target"
    
    #if command -v xfce4-terminal >/dev/null 2>&1; then
    #    xfce4-terminal --title="SSH: $target" --zoom=1 -e "$cmd" &
    #elif command -v gnome-terminal >/dev/null 2>&1; then
    #    gnome-terminal --title="SSH: $target" -- bash -c "$cmd; exec bash" &
    #else
    #    xterm -title "SSH: $target" -bg black -fg white -fa 'Monospace' -fs 11 -e "$cmd" &
    #fi
    konsole --title="SSH: $target" -e bash -c "$cmd; exec bash" & 
}

nova_conexao() {
    local resp=$(yad --title="Adicionar Novo Servidor" --form --center --fixed \
        --window-icon="$ICON_ADD" --image="$ICON_ADD" --image-on-top \
        --field="Apelido (Alias):" \
        --field="Endereço (IP/Host):" \
        --field="Usuário:" \
        --field="Porta:" \
        --button="Salvar:0" --button="Cancelar:1")
    
    [[ $? -ne 0 ]] && return

    local alias=$(echo "$resp" | cut -d'|' -f1)
    local host=$(echo "$resp" | cut -d'|' -f2)
    local user=$(echo "$resp" | cut -d'|' -f3)
    local port=$(echo "$resp" | cut -d'|' -f4)

    if [[ -n "$alias" && -n "$host" ]]; then
        # Evitar duplicatas
        if grep -q "^Host $alias$" "$CONFIG_FILE"; then
            yad --text="O apelido '$alias' já existe!" --image=dialog-error --button="OK:0" --center
        else
            printf "\nHost %s\n    HostName %s\n    User %s\n    Port %s\n" \
                "$alias" "$host" "$user" "$port" >> "$CONFIG_FILE"
            yad --text="Servidor '$alias' cadastrado!" --image=dialog-information --button="OK:0" --center
        fi
    else
        yad --text="Campos obrigatórios vazios!" --image=dialog-warning --button="OK:0" --center
    fi
}

setup_env

while true; do

    LISTA_DADOS=$(awk '
        BEGIN { icon="'"$ICON_SERVER"'" }

        function print_block() {
            if (alias && host) {
                print icon
                print alias
                print host
                print user
                print port
            }
        }

        /^[[:space:]]*Host[[:space:]]+/ {
            print_block()
            alias=$2
            host=""
            user=""
            port=""
        }

        /^[[:space:]]*HostName[[:space:]]+/ { host=$2 }
        /^[[:space:]]*User[[:space:]]+/     { user=$2 }
        /^[[:space:]]*Port[[:space:]]+/     { port=$2 }

        END {
            print_block()
        }

    ' "$CONFIG_FILE")

    SELECAO=$(echo "$LISTA_DADOS" | yad --list --title="SSH Manager Pro" \
        --window-icon="$ICON_SERVER" --center --width=700 --height=450 \
        --column="":IMG --column="Apelido (Alias)" --column="Endereço" --column="Usuário" --column="Porta" \
        --search-column=2 --print-column=2 \
        --button="Conectar!$ICON_CONNECT:0" \
        --button="Novo!$ICON_ADD:10" \
        --button="Sair!$ICON_EXIT:1" \
        --text="<b>Servidores SSH Salvos</b>\n<i>Dica: Dê um duplo clique para conectar.</i>")

    RET=$?

    case $RET in
        0)
            [[ -n "$SELECAO" ]] && conectar "$(echo "$SELECAO" | cut -d'|' -f1)"
            ;;
        10)
            nova_conexao
            ;;
        1 | 252)
            break
            ;;
    esac
done
