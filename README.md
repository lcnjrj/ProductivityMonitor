# ProductivityMonitor📊 Productivity Monitor - Sistema de Monitoramento Automático de Produtividade
# 📊 Productivity Monitor - Sistema de Monitoramento Automático de Produtividade

> Rastreamento inteligente de atividades em Linux/LXQt com detecção de abas de navegadores, geração de relatórios e gráficos visuais

[![Bash](https://img.shields.io/badge/Bash-4.0%2B-green?style=flat&logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)](https://www.linux.org/)
[![LXQt](https://img.shields.io/badge/LXQt-Compatible-blue)](https://lxqt-project.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-2.3-blue)](https://github.com/lcnjrj/productivity-monitor-linux)

---

## 📋 Sobre o Projeto

**Productivity Monitor** é um sistema automatizado de rastreamento de atividades desenvolvido em Shell Script puro que monitora o uso do computador em ambientes Linux (especialmente LXQt/Lubuntu), gerando relatórios detalhados e gráficos visuais sobre como o tempo é gasto durante o dia.

### 🎯 Problema Resolvido

Como administradora de sistemas e profissional com ADHD/TOC, eu precisava entender **objetivamente** como meu tempo era distribuído entre:
- Trabalho produtivo (desenvolvimento, estudo)
- Distrações (redes sociais, YouTube)
- Tempo ocioso (pausas, afastamentos)

Ferramentas comerciais não atendiam porque:
- ❌ São invasivas (enviam dados para nuvem)
- ❌ Não funcionam bem em Linux/LXQt
- ❌ Não detectam **abas específicas** de navegadores
- ❌ Geram relatórios genéricos pouco úteis

**Então criei minha própria solução.**

---

## ✨ Funcionalidades

### Monitoramento Inteligente
- 🔍 **Detecção automática** de aplicações ativas via X11
- 🌐 **Extração de abas/sites de navegadores** (Chrome, Firefox, Brave, Opera, Edge)
- ⏱️ **Detecção de tempo ocioso** precisa via `xprintidle`
- 📊 **Categorização automática** por tipo de atividade
- 💾 **Persistência estruturada** em logs pipe-delimited

### Relatórios e Análises
- 📄 **Relatórios horários automáticos** (um arquivo por dia)
- 📈 **Gráficos visuais com gnuplot** mostrando distribuição temporal
- 🏆 **Top 5 aplicativos por hora** integrados aos gráficos
- 📊 **Estatísticas detalhadas** por categoria de atividade
- 🕐 **Resumos em tempo real** via comando CLI

### Privacidade Total
- 🔒 **100% local** - nenhum dado sai da máquina
- 🚫 **Sem telemetria** ou conexões externas
- 🗂️ **Você controla** onde os dados são salvos
- 🔐 **Pode criptografar** os logs se necessário

### Arquitetura
- 🔄 **Modo daemon** - roda em background sem interferência
- 📁 **Arquivo de relatório por dia** - organização limpa
- 🎨 **Output colorido** no terminal para melhor legibilidade
- 🛡️ **Verificação de dependências** automática
- 📝 **Logs estruturados** pipe-delimited para análise

---

## 🚀 Instalação

### Pré-requisitos

```bash
# Ubuntu/Debian/Lubuntu
sudo apt install xprintidle wmctrl xdotool gnuplot

# Fedora/RHEL
sudo dnf install xprintidle wmctrl xdotool gnuplot

# Arch
sudo pacman -S xprintidle wmctrl xdotool gnuplot
```

### Instalação do Script

```bash
# Clone o repositório
git clone https://github.com/lcnjrj/productivity-monitor-linux.git
cd productivity-monitor-linux

# Tornar executável
chmod +x productivity_monitor.sh

# (Opcional) Instalar globalmente
sudo cp productivity_monitor.sh /usr/local/bin/prodmon
```

### Configuração

Edite o início do script para personalizar:

```bash
# Diretório onde relatórios serão salvos
RELATORIO_DIR="/brain-files/10.MINHA_ATIVIDADE_RALATORIOS_GRAFICOS/claude01b"

# Intervalo de coleta em segundos (padrão: 100s)
INTERVALO_COLETA=100

# Tempo em segundos para considerar usuário ocioso (padrão: 360s = 6min)
TEMPO_OCIOSO_MAX=360
```

---

## 💻 Uso

### Comandos Básicos

```bash
# Iniciar monitoramento em background
./productivity_monitor.sh start

# Ver resumo do dia atual
./productivity_monitor.sh resumo

# Visualizar relatório detalhado de hoje
./productivity_monitor.sh relatorio

# Visualizar relatório de data específica
./productivity_monitor.sh relatorio 2024-12-08

# Gerar e abrir gráfico do dia
./productivity_monitor.sh grafico

# Listar todos os relatórios disponíveis
./productivity_monitor.sh listar

# Parar monitoramento
./productivity_monitor.sh stop

# Ver status do monitor
./productivity_monitor.sh status
```

---

## 📊 Exemplos de Saída

### Resumo no Terminal

```
═══════════════════════════════════════════════════════════════
 RESUMO DE PRODUTIVIDADE - 08/12/2024
═══════════════════════════════════════════════════════════════

⏱ Tempo Total: 08:15:30
✓ Tempo Ativo: 06:45:20 (81.8%)
⏸ Tempo Ocioso: 01:30:10 (18.2%)

📱 Top 10 Aplicativos:
 google-chrome [GitHub - Repository]    02:15:30
 code [project-folder]                   01:45:20
 qterminal                               00:55:40
 firefox [YouTube - Programming]         00:48:10
 spotify                                 00:35:20
 ...

📊 Resumo por Categoria:
 Desenvolvimento / Estudo                04:20:30
 Navegação Web                           01:50:20
 Terminal/Sistema                        00:55:40
 Divertimento                            00:35:20
```

### Gráfico Diário

O script gera automaticamente gráficos PNG com:
- **Barra superior:** Tempo ativo vs ocioso por hora (cores verde/vermelho)
- **Tabela inferior:** Top 5 aplicativos mais usados em cada hora
- **Título:** Resumo do dia com totais e percentuais

**Exemplo:**
```
Relatório de Produtividade - 2024-12-08
Tempo Ativo: 6.5h (81.8%) | Tempo Ocioso: 1.5h

┌─────────────────────────────────────────┐
│ [Gráfico de barras por hora]           │
│                                         │
│ Top 5 Apps por Hora:                   │
│ 09:00 | code (45m), chrome (15m)       │
│ 10:00 | chrome [GitHub] (38m), ...     │
│ ...                                     │
└─────────────────────────────────────────┘
```

---

## 🌟 Diferencial: Detecção de Abas de Navegadores

### Como Funciona

Algoritmo proprietário que:
1. Detecta navegador ativo (Chrome, Firefox, Brave, Opera, Edge)
2. Extrai título da janela com `xdotool`
3. Remove sufixos do navegador via regex
4. Extrai domínio de URLs quando presente
5. Formata output: `google-chrome [GitHub - lcnjrj/project]`

### Exemplos de Detecção

**Antes (v2.2):**
```
google-chrome    02:30:00
```

**Agora (v2.3):**
```
google-chrome [GitHub - Repository]         01:15:20
google-chrome [YouTube - Programming]       00:45:10
google-chrome [Stack Overflow - Question]   00:30:30
```

**Impacto:** Você descobre **EXATAMENTE** onde gasta tempo, não só "estava no Chrome".

---

## 📁 Formato dos Dados

### Log Temporário (pipe-delimited)

```
timestamp|data_hora|status|categoria|app|titulo|tempo_ocioso
1733428800|2024-12-08 10:00:00|ativo|Desenvolvimento|code|main.py|15
1733428900|2024-12-08 10:01:40|ativo|Navegação Web|google-chrome [GitHub]|Repository|22
1733429000|2024-12-08 10:03:20|ocioso|Ocioso|Sistema|Desktop|380
```

### Relatórios Diários

Um arquivo por dia em formato texto legível:

```
~/.prodmon/relatorio_produtividade_2024-12-08.txt
```

Contém:
- Resumo de cada hora
- Top 10 aplicativos da hora
- Categoria de atividades
- Totais e percentuais

### Gráficos

```
~/.prodmon/grafico_diario_2024-12-08.png
```

Imagem PNG com gráfico de barras + tabela de top 5 apps por hora.

---

## 🎓 Casos de Uso Reais

### **1. Auditoria de Tempo de Trabalho**
```
Descobri que passava 2h/dia no YouTube durante
"pausas" que eu achava que eram 30min.

Agora:
✅ Pausas intencionais de 15min
✅ Bloqueio de sites durante horários de trabalho
✅ Produtividade aumentou 30%
```

### **2. Identificação de Distrações**
```
Relatório mostrou:
- 45min/dia no Twitter/X
- 30min/dia em notícias
- 1h/dia em Slack (muitas interrupções)

Ações:
✅ Desativei notificações do Slack
✅ Tempo de redes sociais: apenas almoço
✅ Foco aumentou significativamente
```

### **3. Otimização de Rotina**
```
Descobri meus horários de maior produtividade:
- 09h-12h: Foco máximo (3h ininterruptas)
- 14h-16h: Médio foco (interrupções frequentes)
- 18h-20h: Criatividade (projetos pessoais)

Agora:
✅ Tarefas complexas: manhã
✅ Reuniões/emails: tarde
✅ Estudos/side projects: noite
```

### **4. Validação de Hábitos**
```
Eu achava que estudava 4h/dia.
Relatório mostrou: 2h15 de estudo real.

Motivo: Distrações entre Pomodoros (YouTube, notícias).

Solução:
✅ Timer Pomodoro mais rígido
✅ Pausas offline (desenho, caminhada)
✅ Estudo real subiu para 3h30/dia
```

---

## 🛠️ Implementação Técnica

### Arquitetura do Código

```
productivity_monitor.sh
├── Configuração
│   ├── Variáveis de ambiente
│   └── Diretórios de dados
├── Funções de Sistema
│   ├── obter_tempo_ocioso() - xprintidle
│   ├── obter_janela_ativa() - xdotool + xprop
│   └── categorizar_atividade() - regex patterns
├── Detecção de Abas
│   ├── Extração de título da janela
│   ├── Parsing de sufixos de navegadores
│   ├── Extração de domínios
│   └── Formatação de output
├── Coleta de Dados
│   ├── coletar_dados() - loop principal
│   └── Salvamento em log temporário
├── Processamento
│   ├── gerar_relatorio_horario() - estatísticas
│   ├── gerar_grafico_diario() - gnuplot
│   └── mostrar_resumo_hoje() - CLI output
└── Modo Daemon
    ├── PID management
    ├── Signal handling (SIGINT, SIGTERM)
    └── Loop infinito com sleep
```

### Tecnologias Utilizadas

- **Bash 4.0+** - Linguagem principal
- **X11 Tools** - xprintidle, wmctrl, xdotool, xprop
- **gnuplot** - Geração de gráficos
- **GNU coreutils** - date, awk, grep, sed

### Principais Desafios Técnicos Resolvidos

1. ✅ **Detecção de abas em múltiplos navegadores**
   - Cada navegador tem formato de título diferente
   - Regex complexas para parsing universal
   - Truncamento inteligente de títulos longos

2. ✅ **Cálculo preciso de tempo ocioso**
   - `xprintidle` retorna milissegundos desde último input
   - Conversão e threshold configurável
   - Distinção entre "pausa curta" e "ausente"

3. ✅ **Categorização automática inteligente**
   - Patterns de regex para detectar tipo de app
   - Subcategorização por conteúdo (ex: GitHub vs YouTube no Chrome)
   - Extensível facilmente

4. ✅ **Geração de gráficos complexos com gnuplot**
   - Multiplot (gráfico + tabela)
   - Cores dinâmicas
   - Labels com informações variáveis

5. ✅ **Persistência eficiente**
   - Arquivo por dia (não cresce infinitamente)
   - Formato pipe-delimited (fácil parsing)
   - Backup automático

---

## 🎓 Principais Aprendizados

Desenvolver e **usar diariamente** este projeto me ensinou:

- ✅ **Shell scripting avançado** - Daemon, signal handling, loops não-bloqueantes
- ✅ **Integração X11** - Ferramentas de window management, propriedades de janelas
- ✅ **Regex complexas** - Parsing de strings variáveis, extração de padrões
- ✅ **Processamento de dados** - Agregação temporal, estatísticas, percentuais
- ✅ **Visualização com gnuplot** - Gráficos programáticos, multiplot, customização
- ✅ **Design de daemon** - Background processes, PID files, graceful shutdown
- ✅ **Análise comportamental** - Entender padrões de produtividade objetivamente

---

## 🌟 Diferencial vs Alternativas

### **Vs. RescueTime / Toggl**

| Aspecto | RescueTime/Toggl | Productivity Monitor |
|---------|-----------------|---------------------|
| Privacidade | ❌ Dados na nuvem | ✅ 100% local |
| Linux/LXQt | ⚠️ Suporte limitado | ✅ Nativo |
| Detecção de abas | ❌ Não detecta | ✅ Detecta e categoriza |
| Custo | 💰 Assinatura mensal | ✅ Gratuito, open-source |
| Customização | ❌ Limitada | ✅ Código-fonte acessível |
| Offline | ⚠️ Precisa internet | ✅ Funciona offline |

### **Vs. ActivityWatch**

| Aspecto | ActivityWatch | Productivity Monitor |
|---------|--------------|---------------------|
| Complexidade | ⚠️ Python + DB + Web | ✅ Bash puro |
| Recursos | ⚠️ ~500MB RAM | ✅ ~10MB RAM |
| Setup | ⚠️ Instalação complexa | ✅ Arquivo único |
| Gráficos | ✅ Dashboard web | ✅ PNG estáticos |
| LXQt | ⚠️ As vezes trava | ✅ Estável |

---

## 🐛 Limitações Conhecidas

### Atuais
- Funciona apenas em ambientes X11 (não Wayland ainda)
- Detecção de abas limitada a navegadores principais
- Gráficos são estáticos (não interativos)
- Categorização por regex (pode ter falsos positivos)

### Por Design (não são bugs!)
- **Rastreamento passivo é intencional** - Não interrompe fluxo de trabalho
- **Um arquivo por dia** - Evita crescimento infinito de logs
- **Coleta a cada 100s** - Balance entre precisão e recursos

---

## 🚀 Roadmap Futuro

**Nota:** Atualmente o script atende perfeitamente minhas necessidades. Melhorias futuras dependerão de feedback da comunidade.

Possibilidades:
- [ ] **Suporte Wayland** via ferramentas alternativas
- [ ] **Dashboard web local** (Python Flask) para visualização
- [ ] **Exportação JSON/CSV** para análise externa
- [ ] **Integração com ADHD Time Tracker** (rastreamento manual + automático)
- [ ] **Alertas customizáveis** (ex: "3h seguidas em redes sociais")
- [ ] **Machine learning** para categorização automática melhorada
- [ ] **Mobile companion app** para visualizar dados

---

## 🤝 Contribuindo

Este projeto nasceu de necessidade pessoal e é **usado diariamente**. Contribuições são bem-vindas se:

- Respeitarem a privacidade (100% local)
- Mantiverem funcionamento em LXQt/Lubuntu
- Não adicionarem dependências pesadas
- Forem testadas em ambiente real de uso por pelo menos 1 semana

### Como Contribuir

1. Fork o projeto
2. Teste extensivamente (idealmente 1 semana de monitoramento real)
3. Documente mudanças claramente
4. Abra Pull Request explicando o benefício

---

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 👤 Autora

**Lu Faria** - Administradora de Sistemas Linux | ADHD/OCD | DevOps em Transição

Este script existe porque eu **precisava** entender meu tempo objetivamente. Como pessoa com ADHD, minha percepção de tempo é distorcida - horas passam como minutos, minutos como horas.

Ferramentas comerciais não funcionavam bem no meu setup (Lubuntu/LXQt) e todas enviavam dados para a nuvem (inaceitável para mim). Além disso, nenhuma detectava **qual aba específica** eu estava usando no navegador - informação crucial.

Então criei minha própria ferramenta. E uso ela todos os dias desde 2023.

Os insights que obtive mudaram minha vida produtiva:
- Descobri que subestimava distrações em 200%
- Identifiquei meus horários de pico de produtividade
- Validei (ou refutei) percepções sobre meus hábitos
- Reduzi tempo em redes sociais de 2h para 30min/dia

**Se você também precisa de dados objetivos sobre seu tempo, essa ferramenta é para você.**

### Conecte-se Comigo
- 💼 **GitHub:** [@lcnjrj](https://github.com/lcnjrj)
- 🔗 **LinkedIn:** [Seu LinkedIn]
- 🌐 **Portfolio:** [lcnjrj.github.io/portfolio_2025](https://lcnjrj.github.io/portfolio_2025/)
- 📧 **Email:** lu.faria.dev@gmail.com

---

## 🙏 Agradecimentos

- **Comunidade LXQt** - Por um desktop leve e eficiente
- **Projeto X11** - Por ferramentas poderosas de window management
- **Gnuplot Community** - Por ferramenta de plotting versátil
- **Meu ADHD** - Por me forçar a criar ferramentas de autogestão 😊

---

## 📈 Estatísticas do Projeto

- **Versão atual:** 2.3 (evoluindo desde 2023)
- **Linhas de código:** ~700
- **Dependências:** 4 (xprintidle, wmctrl, xdotool, gnuplot)
- **Uso pessoal:** Diário desde criação
- **Dias monitorados:** 500+ (estimativa)
- **Testado em:** Lubuntu 22.04, Ubuntu 24.04

---

## 🔗 Projetos Relacionados

### Da mesma autora
- [ADHD Time Tracker](https://github.com/lcnjrj/adhd-time-tracker-bash) - Rastreamento **manual** de tarefas offline
- [Disk Analyzer](https://github.com/lcnjrj/disk-analyzer-bash) - Análise de uso de disco
- [Portfolio](https://lcnjrj.github.io/portfolio_2025/) - Outros projetos

### Ecossistema de Produtividade
**Productivity Monitor (este)** + **ADHD Time Tracker** = Visão 360° de produtividade:
- **Automático (Monitor):** Atividades no computador, passivo
- **Manual (ADHD):** Atividades offline (livros, desenho), intencional

Juntos, oferecem análise completa de como você gasta seu tempo.

---

⭐ **Se esta ferramenta te ajuda a entender seu tempo, considere dar uma estrela!** ⭐  
🧠 **Tem ADHD/TDAH? Use e compartilhe sua experiência!**  
🤝 **Melhorias? Abra uma issue ou PR!**

---

*"Você não pode gerenciar o que não consegue medir. Agora você pode medir."*

---

