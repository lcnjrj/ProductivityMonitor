#!/bin/bash

################################################################################
# Productivity Monitor for Linux
#
# Automated time tracking system for Linux/LXQt environments
# Generates detailed reports and visual charts of computer usage
#Descrição: Monitora atividade do usuário, gera relatórios e gráficos
# Agora detecta títulos/sites das abas abertas em navegadores!
# Author: Luciana Jorge de Faria (@lcnjrj)
# Version: 2.3.0
# License: MIT
# Repository: https://github.com/lcnjrj/ProductivityMonitor
################################################################################


# Configurações
RELATORIO_DIR="/brain-files/10.MINHA_ATIVIDADE_RALATORIOS_GRAFICOS/claude01b"
LOG_TEMP="$RELATORIO_DIR/temp_log.dat"
INTERVALO_COLETA=100 # segundos
TEMPO_OCIOSO_MAX=360 # 3 minutos para considerar ocioso

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Criar diretório se não existir
mkdir -p "$RELATORIO_DIR"

################################################################################
# Funções Auxiliares
################################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Obter arquivo de relatório diário atual
obter_relatorio_diario() {
    local data_atual=$(date "+%Y-%m-%d")
    echo "$RELATORIO_DIR/relatorio_produtividade_caude_top05_${data_atual}.txt"
}

# Obter arquivo de gráfico diário atual
obter_grafico_diario() {
    local data_atual=$(date "+%Y-%m-%d")
    echo "$RELATORIO_DIR/grafico_diario_${data_atual}.png"
}

# Verificar dependências
verificar_dependencias() {
    local deps=("xprintidle" "wmctrl" "xdotool" "gnuplot")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Dependências faltando: ${missing[*]}"
        echo "Instale com: sudo apt install xprintidle wmctrl xdotool gnuplot"
        exit 1
    fi
}

# Obter tempo ocioso em segundos
obter_tempo_ocioso() {
    local idle_ms=$(xprintidle 2>/dev/null || echo "0")
    echo $((idle_ms / 1000))
}

# Obter janela ativa com detalhes de abas de navegadores
obter_janela_ativa() {
    local window_id=$(xdotool getactivewindow 2>/dev/null)

    if [ -n "$window_id" ]; then
        local window_name=$(xdotool getwindowname "$window_id" 2>/dev/null)
        local window_class=$(xprop -id "$window_id" WM_CLASS 2>/dev/null | cut -d'"' -f4)

        # Para navegadores, extrair informações da aba
        local app_display="$window_class"
        case "$window_class" in
            *firefox*|*Firefox*|*chrome*|*Chrome*|*chromium*|*Chromium*|*brave*|*Brave*|*opera*|*Opera*|*Edge*|*edge*)
                # Remover sufixos do navegador do título
                local site=$(echo "$window_name" | sed -E 's/ - (Mozilla Firefox|Google Chrome|Chromium|Brave Browser|Brave|Opera|Microsoft Edge|Edge).*$//g' | sed -E 's/ — .*$//g')

                # Tentar extrair domínio de URLs
                if [[ "$site" =~ ^https?:// ]]; then
                    site=$(echo "$site" | sed -E 's|https?://([^/]+).*|\1|' | sed 's/www\.//')
                fi

                # Limpar e formatar
                site=$(echo "$site" | sed 's/^ *//;s/ *$//') # Trim espaços

                # Se tem conteúdo útil, adicionar ao display
                if [ -n "$site" ] && [ "$site" != "$window_class" ] && [ ${#site} -gt 2 ]; then
                    # Limitar tamanho
                    if [ ${#site} -gt 45 ]; then
                        site="${site:0:42}..."
                    fi
                    app_display="$window_class [$site]"
                fi
                ;;
        esac

        echo "${app_display}|${window_name:-Unknown}"
    else
        echo "Sistema|Desktop"
    fi
}

# Categorizar atividade
categorizar_atividade() {
    local app="$1"
    local categoria=""

    case "$app" in
        *firefox*|*chrome*|*chromium*|*brave*|*opera*|*Edge*)
            categoria="Navegação Web"
            ;;
        *code*|*atom*|*sublime*|*vim*|*emacs*|*gedit*|*kate*|*Kwrite*|*Alura*|*DIO*|*ADA*|*Github*)
            categoria="Desenvolvimento / Estudo"
            ;;
        *terminal*|*konsole*|*qterminal*|*synaptic*|*qps*)
            categoria="Terminal/Sistema"
            ;;
        *libreoffice*|*writer*|*calc*|*impress*)
            categoria="Produtividade Office"
            ;;
        *gimp*|*inkscape*|*krita*|*blender*|*Audacity*)
            categoria="Design/Edição/Multimidia"
            ;;
        *telegram*|*discord*|*slack*|*teams*|*signal*|*Bluesky*|*X.com*)
            categoria="Comunicação"
            ;;
        *vlc*|*mpv*|*spotify*|*Deezer*|*Disney*|*Hbo*|*Max*|*looke*|*Youtube*|*Last*)
            categoria="Divertimento"
            ;;
        *Sistema*|*Desktop*|*pcmanfm*)
            categoria="Sistema"
            ;;
        *)
            categoria="Outros"
            ;;
    esac

    echo "$categoria"
}

################################################################################
# Coleta de Dados
################################################################################

coletar_dados() {
    local timestamp=$(date +%s)
    local data_hora=$(date "+%Y-%m-%d %H:%M:%S")
    local tempo_ocioso=$(obter_tempo_ocioso)
    local janela_info=$(obter_janela_ativa)
    local app=$(echo "$janela_info" | cut -d'|' -f1)
    local titulo=$(echo "$janela_info" | cut -d'|' -f2)
    local categoria=$(categorizar_atividade "$app")
    local status="ativo"

    if [ "$tempo_ocioso" -gt "$TEMPO_OCIOSO_MAX" ]; then
        status="ocioso"
        categoria="Ocioso"
    fi

    # Salvar em arquivo temporário
    echo "$timestamp|$data_hora|$status|$categoria|$app|$titulo|$tempo_ocioso" >> "$LOG_TEMP"
}

################################################################################
# Processamento e Relatório
################################################################################

gerar_relatorio_horario() {
    if [ ! -f "$LOG_TEMP" ]; then
        log_warn "Nenhum dado coletado ainda"
        return
    fi

    local data_atual=$(date "+%Y-%m-%d")
    local relatorio_hoje=$(obter_relatorio_diario)
    local hora_atual=$(date "+%H:00")
    local hora_inicio=$(date -d "1 hour ago" "+%s")
    local hora_fim=$(date "+%s")

    # Calcular estatísticas da última hora
    local total_tempo=0
    local tempo_ativo=0
    local tempo_ocioso=0
    declare -A tempo_apps
    declare -A tempo_categorias

    while IFS='|' read -r timestamp data_hora status categoria app titulo idle; do
        if [ "$timestamp" -ge "$hora_inicio" ] && [ "$timestamp" -le "$hora_fim" ]; then
            total_tempo=$((total_tempo + INTERVALO_COLETA))

            if [ "$status" = "ativo" ]; then
                tempo_ativo=$((tempo_ativo + INTERVALO_COLETA))

                # Rastrear por aplicativo específico
                tempo_apps["$app"]=$((${tempo_apps["$app"]:-0} + INTERVALO_COLETA))
                tempo_categorias["$categoria"]=$((${tempo_categorias["$categoria"]:-0} + INTERVALO_COLETA))
            else
                tempo_ocioso=$((tempo_ocioso + INTERVALO_COLETA))
            fi
        fi
    done < "$LOG_TEMP"

    # Formatar tempo em HH:MM:SS
    formatar_tempo() {
        local segundos=$1
        printf "%02d:%02d:%02d" $((segundos/3600)) $((segundos%3600/60)) $((segundos%60))
    }

    # Escrever relatório
    {
        echo "═══════════════════════════════════════════════════════════════"
        echo " RELATÓRIO DE PRODUTIVIDADE - $data_atual $hora_atual"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "📊 RESUMO DA ÚLTIMA HORA:"
        echo " └─ Tempo Total: $(formatar_tempo $total_tempo)"
        echo " └─ Tempo Ativo: $(formatar_tempo $tempo_ativo) ($(awk "BEGIN {printf \"%.1f\", ($tempo_ativo/$total_tempo)*100}")%)"
        echo " └─ Tempo Ocioso: $(formatar_tempo $tempo_ocioso) ($(awk "BEGIN {printf \"%.1f\", ($tempo_ocioso/$total_tempo)*100}")%)"
        echo ""

        echo "📱 APLICATIVOS USADOS (Top 10):"
        for app in "${!tempo_apps[@]}"; do
            local tempo=${tempo_apps[$app]}
            local percentual=$(awk "BEGIN {printf \"%.1f\", ($tempo/$tempo_ativo)*100}")
            echo "$tempo|$app|$percentual"
        done | sort -t'|' -k1 -rn | head -10 | while IFS='|' read tempo app perc; do
            printf " ├─ %-35s %s (%s%%)\n" "$app" "$(formatar_tempo $tempo)" "$perc"
        done

        echo ""
        echo "📋 RESUMO POR CATEGORIA:"
        for categoria in "${!tempo_categorias[@]}"; do
            local tempo=${tempo_categorias[$categoria]}
            local percentual=$(awk "BEGIN {printf \"%.1f\", ($tempo/$tempo_ativo)*100}")
            printf " ├─ %-25s %s (%s%%)\n" "$categoria:" "$(formatar_tempo $tempo)" "$percentual"
        done | sort -k2 -rn

        echo ""
        echo "───────────────────────────────────────────────────────────────"
        echo ""
    } >> "$relatorio_hoje"

    log_info "Relatório horário adicionado: $hora_atual → $relatorio_hoje"
}

################################################################################
# Geração de Gráficos com Top 5 Apps
################################################################################

gerar_grafico_diario() {
    if [ ! -f "$LOG_TEMP" ]; then
        log_warn "Sem dados para gerar gráfico"
        return
    fi

    local data_atual=$(date "+%Y-%m-%d")
    local inicio_dia=$(date -d "$data_atual 00:00:00" "+%s")
    local fim_dia=$(date -d "$data_atual 23:59:59" "+%s")
    local grafico_hoje=$(obter_grafico_diario)

    # Estruturas de dados
    declare -A horas_ativo
    declare -A horas_ocioso
    declare -A apps_por_hora

    for h in {0..23}; do
        horas_ativo[$h]=0
        horas_ocioso[$h]=0
        apps_por_hora[$h]=""
    done

    # Coletar dados por hora e por app
    declare -A tempo_apps_hora

    while IFS='|' read -r timestamp data_hora status categoria app titulo idle; do
        if [ "$timestamp" -ge "$inicio_dia" ] && [ "$timestamp" -le "$fim_dia" ]; then
            local hora=$(date -d "@$timestamp" "+%H")
            hora=$((10#$hora))

            if [ "$status" = "ativo" ]; then
                horas_ativo[$hora]=$((${horas_ativo[$hora]} + INTERVALO_COLETA))

                # Acumular tempo por app específico em cada hora
                local chave="${hora}_${app}"
                tempo_apps_hora["$chave"]=$((${tempo_apps_hora["$chave"]:-0} + INTERVALO_COLETA))
            else
                horas_ocioso[$hora]=$((${horas_ocioso[$hora]} + INTERVALO_COLETA))
            fi
        fi
    done < "$LOG_TEMP"

    # Processar top 5 apps por hora
    for h in {0..23}; do
        local top5=""

        # Coletar apps desta hora
        for chave in "${!tempo_apps_hora[@]}"; do
            local hora_chave=$(echo "$chave" | cut -d'_' -f1)
            if [ "$hora_chave" = "$h" ]; then
                local app_nome=$(echo "$chave" | cut -d'_' -f2-)
                local tempo=${tempo_apps_hora["$chave"]}
                echo "$tempo|$app_nome"
            fi
        done | sort -t'|' -k1 -rn | head -5 | while IFS='|' read tempo app; do
            if [ -z "$top5" ]; then
                top5="$app ($(awk "BEGIN {printf \"%.0f\", $tempo/60}")m)"
            else
                top5="$top5, $app ($(awk "BEGIN {printf \"%.0f\", $tempo/60}")m)"
            fi
            echo "$top5" > /tmp/top5_$h.tmp
        done

        if [ -f /tmp/top5_$h.tmp ]; then
            apps_por_hora[$h]=$(tail -1 /tmp/top5_$h.tmp)
            rm /tmp/top5_$h.tmp
        else
            apps_por_hora[$h]="Sem atividade"
        fi
    done

    # Criar arquivo de dados para gnuplot
    local data_file="$RELATORIO_DIR/plot_data.dat"
    {
        echo "# Hora Ativo Ocioso"
        for h in {0..23}; do
            printf "%02d %.2f %.2f\n" $h \
                $(awk "BEGIN {print ${horas_ativo[$h]}/60}") \
                $(awk "BEGIN {print ${horas_ocioso[$h]}/60}")
        done
    } > "$data_file"

    # Criar arquivo com top 5 apps
    local apps_file="$RELATORIO_DIR/top5_apps.dat"
    {
        for h in {0..23}; do
            echo "$h|${apps_por_hora[$h]}"
        done
    } > "$apps_file"

    # Calcular totais do dia
    local total_ativo=0
    local total_ocioso=0

    for h in {0..23}; do
        total_ativo=$((total_ativo + ${horas_ativo[$h]}))
        total_ocioso=$((total_ocioso + ${horas_ocioso[$h]}))
    done

    local horas_ativo_total=$(awk "BEGIN {printf \"%.1f\", $total_ativo/3600}")
    local horas_ocioso_total=$(awk "BEGIN {printf \"%.1f\", $total_ocioso/3600}")
    local percentual_ativo=$(awk "BEGIN {printf \"%.1f\", ($total_ativo/($total_ativo+$total_ocioso))*100}")

    # Gerar gráfico com gnuplot
    gnuplot <<EOF
    set terminal pngcairo size 1800,1000 enhanced font 'Arial,10'
    set output '$grafico_hoje'
    set multiplot layout 2,1

    # Gráfico principal - barras
    set title "Relatório de Produtividade - $data_atual\nTempo Ativo: ${horas_ativo_total}h (${percentual_ativo}%) | Tempo Ocioso: ${horas_ocioso_total}h" font 'Arial Bold,16'
    set xlabel "Hora do Dia" font 'Arial,12'
    set ylabel "Minutos" font 'Arial,12'
    set xrange [-0.5:23.5]
    set yrange [0:*]
    set style data histogram
    set style histogram clustered gap 1
    set style fill solid 1.0 border -1
    set boxwidth 0.9
    set xtics 0,1,23 font 'Arial,10'
    set ytics font 'Arial,10'
    set grid ytics linetype 0 linewidth 0.5
    set key outside right top font 'Arial,11'
    set datafile separator whitespace
    set linetype 1 lc rgb '#2ecc71'
    set linetype 2 lc rgb '#e74c3c'

    plot '$data_file' using 2:xtic(1) title 'Tempo Ativo' lt 1, \
         '' using 3 title 'Tempo Ocioso' lt 2

    # Tabela com Top 5 Apps por hora
    unset xlabel
    unset ylabel
    unset ytics
    unset xtics
    unset grid
    unset key
    set border 0
    set title "Top 5 Aplicativos Mais Usados por Hora" font 'Arial Bold,14'
    set yrange [0:24]
    set xrange [0:10]

    set label 1 "Hora | Top 5 Aplicativos" at 0.5,23.5 font 'Arial Bold,11' front
    $(
        for h in {0..23}; do
            apps="${apps_por_hora[$h]}"
            if [ ${#apps} -gt 90 ]; then
                apps="${apps:0:87}..."
            fi
            echo "set label $((h+2)) sprintf(\"%02d:00 | %s\", $h, \"$apps\") at 0.5,$((22-h)) font 'Arial,9' front"
        done
    )

    plot NaN notitle

    unset multiplot
EOF

    if [ -f "$grafico_hoje" ]; then
        log_info "Gráfico gerado: $grafico_hoje"
    else
        log_error "Falha ao gerar gráfico"
    fi
}

################################################################################
# Modo Daemon
################################################################################

iniciar_monitoramento() {
    log_info "Iniciando monitoramento de produtividade..."
    verificar_dependencias

    # Criar arquivo de PID
    local pid_file="$RELATORIO_DIR/monitor.pid"
    echo $$ > "$pid_file"

    # Inicializar relatório se for novo dia
    echo -e "${GREEN}📄 Relatórios Diários (um arquivo por dia):${NC}"
    local count=0
    for arquivo in "$RELATORIO_DIR"/relatorio_produtividade_caude_top05_*.txt; do
        if [ -f "$arquivo" ]; then
            local data=$(basename "$arquivo" | grep -oP '\d{4}-\d{2}-\d{2}')
            local tamanho=$(du -h "$arquivo" | cut -f1)
            local linhas=$(wc -l < "$arquivo")
            printf " %s - %s (%s linhas)\n" "$data" "$tamanho" "$linhas"
            count=$((count + 1))
        fi
    done
    [ $count -eq 0 ] && echo " Nenhum relatório encontrado"

    echo -e "\n${GREEN}📊 Gráficos:${NC}"
    count=0
    for arquivo in "$RELATORIO_DIR"/grafico_*.png; do
        if [ -f "$arquivo" ]; then
            local nome=$(basename "$arquivo" .png)
            printf " %s\n" "$nome"
            count=$((count + 1))
        fi
    done
    [ $count -eq 0 ] && echo " Nenhum gráfico encontrado"

    echo -e "\n${BLUE}───────────────────────────────────────────────────────────────${NC}\n"

    local contador=0
    local ultima_hora=$(date "+%H")
    local ultimo_dia=$(date "+%Y-%m-%d")

    trap 'log_info "Encerrando monitor..."; rm -f "$pid_file" "$LOG_TEMP"; exit 0' SIGINT SIGTERM

    while true; do
        coletar_dados

        # Verificar se mudou o dia
        local data_atual=$(date "+%Y-%m-%d")
        if [ "$data_atual" != "$ultimo_dia" ]; then
            log_info "Novo dia detectado: $data_atual"
            log_info "Criando novo arquivo de relatório: $(obter_relatorio_diario)"
            ultimo_dia="$data_atual"
            # Limpar log temporário para novo dia (opcional)
            # rm -f "$LOG_TEMP"
        fi

        # A cada hora, gerar relatório e gráfico
        local hora_atual=$(date "+%H")
        if [ "$hora_atual" != "$ultima_hora" ]; then
            gerar_relatorio_horario
            gerar_grafico_diario
            ultima_hora=$hora_atual
        fi

        # Mostrar status a cada 10 minutos
        contador=$((contador + 1))
        if [ $((contador % 10)) -eq 0 ]; then
            local relatorio_atual=$(obter_relatorio_diario)
            log_info "Monitor ativo - $(date '+%Y-%m-%d %H:%M:%S') - Relatório: $(basename "$relatorio_atual")"
        fi

        sleep "$INTERVALO_COLETA"
    done
}

################################################################################
# Visualização de Relatórios
################################################################################

visualizar_relatorio() {
    local relatorio_hoje=$(obter_relatorio_diario)

    if [ ! -f "$relatorio_hoje" ]; then
        log_error "Nenhum relatório encontrado para hoje ($relatorio_hoje)"
        # Mostrar relatórios disponíveis
        echo -e "${YELLOW}Relatórios disponíveis:${NC}"
        ls -la "$RELATORIO_DIR"/relatorio_produtividade_caude_top05_*.txt 2>/dev/null || echo "Nenhum relatório encontrado"
        exit 1
    fi

    less -R "$relatorio_hoje"
}

visualizar_relatorio_data() {
    local data="$1"
    local relatorio="$RELATORIO_DIR/relatorio_produtividade_caude_top05_${data}.txt"

    if [ ! -f "$relatorio" ]; then
        log_error "Relatório não encontrado para $data"
        echo -e "${YELLOW}Relatórios disponíveis:${NC}"
        ls -la "$RELATORIO_DIR"/relatorio_produtividade_caude_top05_*.txt 2>/dev/null || echo "Nenhum relatório encontrado"
        exit 1
    fi

    less -R "$relatorio"
}

mostrar_resumo_hoje() {
    if [ ! -f "$LOG_TEMP" ]; then
        log_warn "Nenhum dado coletado hoje"
        return
    fi

    local data_atual=$(date "+%Y-%m-%d")
    local inicio_dia=$(date -d "$data_atual 00:00:00" "+%s")
    local total_ativo=0
    local total_ocioso=0
    declare -A apps_tempo
    declare -A categorias

    while IFS='|' read -r timestamp data_hora status categoria app titulo idle; do
        if [ "$timestamp" -ge "$inicio_dia" ]; then
            if [ "$status" = "ativo" ]; then
                total_ativo=$((total_ativo + INTERVALO_COLETA))
                apps_tempo["$app"]=$((${apps_tempo["$app"]:-0} + INTERVALO_COLETA))
                categorias["$categoria"]=$((${categorias["$categoria"]:-0} + INTERVALO_COLETA))
            else
                total_ocioso=$((total_ocioso + INTERVALO_COLETA))
            fi
        fi
    done < "$LOG_TEMP"

    local total=$((total_ativo + total_ocioso))

    formatar_tempo() {
        local segundos=$1
        printf "%02d:%02d:%02d" $((segundos/3600)) $((segundos%3600/60)) $((segundos%60))
    }

    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} RESUMO DE PRODUTIVIDADE - $(date '+%d/%m/%Y')${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"

    echo -e "${GREEN}⏱ Tempo Total:${NC} $(formatar_tempo $total)"
    echo -e "${GREEN}✓ Tempo Ativo:${NC} $(formatar_tempo $total_ativo) ($(awk "BEGIN {printf \"%.1f\", ($total_ativo/$total)*100}")%)"
    echo -e "${RED}⏸ Tempo Ocioso:${NC} $(formatar_tempo $total_ocioso) ($(awk "BEGIN {printf \"%.1f\", ($total_ocioso/$total)*100}")%)\n"

    echo -e "${YELLOW}📱 Top 10 Aplicativos:${NC}"
    for app in "${!apps_tempo[@]}"; do
        echo "${apps_tempo[$app]} $app"
    done | sort -rn | head -10 | while read tempo app; do
        printf " %-35s %s\n" "$app" "$(formatar_tempo $tempo)"
    done

    echo -e "\n${YELLOW}📊 Resumo por Categoria:${NC}"
    for categoria in "${!categorias[@]}"; do
        echo "${categorias[$categoria]} $categoria"
    done | sort -rn | head -5 | while read tempo cat; do
        printf " %-25s %s\n" "$cat" "$(formatar_tempo $tempo)"
    done

    echo -e "\n${BLUE}───────────────────────────────────────────────────────────────${NC}\n"

    local grafico_hoje=$(obter_grafico_diario)
    if [ -f "$grafico_hoje" ]; then
        echo -e "${GREEN}📈 Gráfico disponível em:${NC} $grafico_hoje"
        echo -e " Abrir com: xdg-open \"$grafico_hoje\"\n"
    fi
}

################################################################################
# Menu Principal
################################################################################

mostrar_ajuda() {
    cat <<EOF
${BLUE}═══════════════════════════════════════════════════════════════${NC}
      Sistema de Monitoramento de Produtividade para LXQt v2.3
       Com Detecção de Abas/Sites em Navegadores
${BLUE}═══════════════════════════════════════════════════════════════${NC}

${GREEN}Uso:${NC} $0 [OPÇÃO]

${YELLOW}Opções:${NC}
  start           Iniciar monitoramento em background
  stop            Parar monitoramento
  status          Mostrar status do monitor
  resumo          Mostrar resumo do dia atual
  relatorio       Visualizar relatório de hoje
  relatorio YYYY-MM-DD  Visualizar relatório de data específica
  grafico         Gerar e abrir gráfico do dia
  listar          Listar todos os relatórios disponíveis
  help            Mostrar esta ajuda

${GREEN}Novidades v2.3:${NC}
  • Detecta ABAS ABERTAS em navegadores (Chrome, Firefox, Brave, etc)
  • Mostra títulos/sites específicos: "google-chrome [YouTube]"
  • Extrai domínios de URLs automaticamente
  • Formata títulos longos (máx 45 caracteres)

${GREEN}Exemplos de detecção:${NC}
  google-chrome [GitHub - Repository]
  firefox [YouTube - Video Title]
  brave [Stack Overflow - Question]

${GREEN}Exemplos de uso:${NC}
  $0 start                    # Iniciar monitoramento
  $0 resumo                   # Ver resumo de hoje
  $0 relatorio                # Ver relatório de hoje
  $0 relatorio 2024-01-15     # Ver relatório de 15/01/2024
  $0 grafico                  # Gerar gráfico
  $0 listar                   # Listar todos os relatórios

${GREEN}Arquivos (criados um por dia):${NC}
  Relatórios: $RELATORIO_DIR/relatorio_produtividade_caude_top05_YYYY-MM-DD.txt
  Gráficos:   $RELATORIO_DIR/grafico_diario_YYYY-MM-DD.png

EOF
}

listar_relatorios() {
    echo -e "${GREEN}📄 Relatórios disponíveis:${NC}"
    local count=0
    for arquivo in "$RELATORIO_DIR"/relatorio_produtividade_caude_top05_*.txt; do
        if [ -f "$arquivo" ]; then
            local data=$(basename "$arquivo" | grep -oP '\d{4}-\d{2}-\d{2}')
            local tamanho=$(du -h "$arquivo" | cut -f1)
            local linhas=$(wc -l < "$arquivo")
            printf " %s - %s (%s linhas)\n" "$data" "$tamanho" "$linhas"
            count=$((count + 1))
        fi
    done
    [ $count -eq 0 ] && echo " Nenhum relatório encontrado"

    echo -e "\n${GREEN}📊 Gráficos disponíveis:${NC}"
    count=0
    for arquivo in "$RELATORIO_DIR"/grafico_*.png; do
        if [ -f "$arquivo" ]; then
            local nome=$(basename "$arquivo" .png)
            printf " %s\n" "$nome"
            count=$((count + 1))
        fi
    done
    [ $count -eq 0 ] && echo " Nenhum gráfico encontrado"
}

case "${1:-help}" in
    start)
        iniciar_monitoramento
        ;;
    stop)
        if [ -f "$RELATORIO_DIR/monitor.pid" ]; then
            kill $(cat "$RELATORIO_DIR/monitor.pid") 2>/dev/null
            rm -f "$RELATORIO_DIR/monitor.pid"
            log_info "Monitor parado"
        else
            log_warn "Monitor não está rodando"
        fi
        ;;
    status)
        if [ -f "$RELATORIO_DIR/monitor.pid" ] && kill -0 $(cat "$RELATORIO_DIR/monitor.pid") 2>/dev/null; then
            log_info "Monitor está ATIVO (PID: $(cat "$RELATORIO_DIR/monitor.pid"))"
            echo "Data atual: $(date '+%Y-%m-%d')"
            echo "Relatório atual: $(obter_relatorio_diario)"
            echo "Log temporário: $LOG_TEMP"
            if [ -f "$LOG_TEMP" ]; then
                echo "Linhas no log: $(wc -l < "$LOG_TEMP")"
            fi
        else
            log_warn "Monitor está INATIVO"
        fi
        ;;
    resumo)
        mostrar_resumo_hoje
        ;;
    relatorio)
        if [ -n "$2" ]; then
            visualizar_relatorio_data "$2"
        else
            visualizar_relatorio
        fi
        ;;
    grafico)
        gerar_grafico_diario
        local grafico_hoje=$(obter_grafico_diario)
        if [ -f "$grafico_hoje" ]; then
            xdg-open "$grafico_hoje" &
        fi
        ;;
    listar)
        listar_relatorios
        ;;
    help|--help|-h)
        mostrar_ajuda
        ;;
    *)
        log_error "Opção inválida: $1"
        mostrar_ajuda
        exit 1
        ;;
esac
