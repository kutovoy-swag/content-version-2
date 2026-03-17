#!/bin/bash
# Фабрика Контента — Установщик v2.5
set -e

# === Цвета (только если терминал поддерживает) ===
if [ -t 1 ] || [ -n "$FORCE_COLOR" ]; then
  BOLD="\033[1m"
  DIM="\033[2m"
  RESET="\033[0m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  CYAN="\033[36m"
  RED="\033[31m"
  GOLD="\033[33;1m"
else
  BOLD="" DIM="" RESET="" GREEN="" YELLOW="" CYAN="" RED="" GOLD=""
fi
CHECK="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"
ARROW="${CYAN}→${RESET}"

# Force color in pipe mode
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[32m"
CYAN="\033[36m"
RED="\033[31m"
GOLD="\033[33;1m"
CHECK="${GREEN}✓${RESET}"
CROSS="${RED}✗${RESET}"
ARROW="${CYAN}→${RESET}"

# === Динамический маскот ===
# Цвета
YF1="\033[38;5;220m"; YF2="\033[38;5;214m"; YF3="\033[38;5;178m"; YF4="\033[38;5;136m"
YB1="\033[48;5;220m"; YB2="\033[48;5;214m"; YB3="\033[48;5;178m"
RF1="\033[38;5;196m"; RF2="\033[38;5;160m"; RF3="\033[38;5;124m"
RB1="\033[48;5;160m"; RB2="\033[48;5;124m"; RB3="\033[48;5;88m"
PF1="\033[38;5;141m"; PF2="\033[38;5;98m"; PF3="\033[38;5;55m"
PB1="\033[48;5;98m"; PB2="\033[48;5;55m"; PB3="\033[48;5;54m"
EB="\033[48;5;23m"; EP="\033[48;5;80m"
R="\033[0m"; B="\033[1m"; D="\033[2m"

show_mascot() {
  local tier="${1:-constructor}"
  local F1 F2 F3 B1 B2 B3 TITLE SUB
  case "$tier" in
    vip|vipfactory)
      F1="$PF1"; F3="$PF3"; B1="$PB1"; B2="$PB2"; B3="$PB3"
      TITLE="${B}${PF1}VIP Фабрика${R}"; SUB="${PF2}Полная система создания контента${R}" ;;
    5agents)
      F1="$RF1"; F3="$RF3"; B1="$RB1"; B2="$RB2"; B3="$RB3"
      TITLE="${B}${RF1}5 Агентов${R}"; SUB="${RF2}Команда ИИ-агентов для контента${R}" ;;
    *)
      F1="$YF1"; F3="$YF3"; B1="$YB1"; B2="$YB2"; B3="$YB3"
      TITLE="${B}${YF2}Фабрика Контента${R}"; SUB="${YF3}ИИ-система для создания контента${R}" ;;
  esac
  clear 2>/dev/null || true
  echo ""
  echo -e "          ${F1}▀▄${R}     ${F1}▄▀${R}"
  echo -e "         ${B1}${F3} ▄▄▄▄▄▄▄▄▄ ${R}"
  echo -e "      ${B2}${F1}▐${B1}               ${B2}▌${R}"
  echo -e "      ${B2}${F1}▐${B1}  ${EB}    ${B1}   ${EB}    ${B1}  ${B2}▌${R}"
  echo -e "      ${B2}${F1}▐${B1}  ${EB} ${EP}  ${EB} ${B1}   ${EB} ${EP}  ${EB} ${B1}  ${B2}▌${R}"
  echo -e "      ${B2}${F1}▐${B1}               ${B2}▌${R}"
  echo -e "      ${B2}${F1}▐${B1}               ${B2}▌${R}"
  echo -e "      ${B3}${F3} ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ${R}"
  echo -e "           ${B1}  ${R}   ${B1}  ${R}"
  echo -e "           ${B3}  ${R}   ${B3}  ${R}"
  echo ""
  echo -e "  ${TITLE}"
  echo -e "  ${SUB}"
  echo -e "  ${D}Макс Галсон · galson.pro${R}"
  echo ""
}

show_mascot "constructor"

# === Шаг 1: Токен ===
echo -e "${BOLD}Шаг 1 из 7${RESET} ${DIM}— Авторизация${RESET}"
echo ""
echo -e "  Токен можно получить в боте ${CYAN}@galsonproAIbot${RESET}"
echo ""
read -p "  Введи токен доступа: " TOKEN < /dev/tty

if [ -z "$TOKEN" ]; then
  echo -e "\n  ${CROSS} Токен не указан"
  exit 1
fi

echo -ne "\n  Проверяю токен... "
VERIFY=$(curl -sf --connect-timeout 10 --max-time 15 "https://bot.galson.pro/api/factory/verify?token=${TOKEN}&platform=$(uname -s | tr '[:upper:]' '[:lower:]')" 2>/dev/null)
if [ $? -ne 0 ]; then
  echo -e "${RED}отказано${RESET}"
  echo -e "  ${CROSS} Токен недействителен или отозван"
  exit 1
fi

VERSION=$(echo $VERIFY | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
USER_NAME=$(echo $VERIFY | grep -o '"user":"[^"]*"' | cut -d'"' -f4)
TIER=$(echo $VERIFY | grep -o '"tier":"[^"]*"' | cut -d'"' -f4)
[ -z "$TIER" ] && TIER="constructor"

# Определяем набор агентов по тиру
STANDARD_AGENTS="coordinator copywriter marketer designer tech brain"
MULTI_AGENT=false
if [ "$TIER" = "5agents" ] || [ "$TIER" = "vip" ]; then
  MULTI_AGENT=true
fi

TIER_LABEL="Конструктор"
[ "$TIER" = "5agents" ] && TIER_LABEL="5 Агентов"
[ "$TIER" = "vip" ] && TIER_LABEL="VIP Фабрика"

echo -e "${GREEN}ок${RESET}"

show_mascot "${TIER}"
echo -e "  ${CHECK} Привет, ${BOLD}${USER_NAME}${RESET}! Тариф: ${BOLD}${TIER_LABEL}${RESET} | v${VERSION}"

# === Платформа ===
VARIANT="openclaw"

# === Шаг 3: Папка ===
echo ""
echo -e "${BOLD}Шаг 2 из 7${RESET} ${DIM}— Папка установки${RESET}"
echo ""

PATHS=()
IDX=0

# --- Вариант A: workspace из openclaw.json (если OpenClaw обнаружен) ---
OC_WORKSPACE=""
if [ "$HAS_OPENCLAW" = true ] || [ "$VARIANT" = "openclaw" ]; then
  OC_CONFIG="$HOME/.openclaw/openclaw.json"
  if [ -f "$OC_CONFIG" ]; then
    OC_WORKSPACE=$(grep -o '"workspace"[[:space:]]*:[[:space:]]*"[^"]*"' "$OC_CONFIG" | head -1 | cut -d'"' -f4 2>/dev/null || true)
    if [ -n "$OC_WORKSPACE" ]; then
      OC_WORKSPACE="${OC_WORKSPACE/#\~/$HOME}"
    fi
  fi
fi

if [ -n "$OC_WORKSPACE" ] && [ -d "$OC_WORKSPACE" ]; then
  IDX=$((IDX+1))
  echo -e "    ${CYAN}${IDX}${RESET}) 📁 ${BOLD}${OC_WORKSPACE}${RESET}"
  if [ -f "$OC_WORKSPACE/SOUL.md" ]; then
    echo -e "       ${DIM}Workspace из openclaw.json (SOUL.md найден)${RESET}"
  else
    echo -e "       ${DIM}Workspace из openclaw.json${RESET}"
  fi
  PATHS+=("$OC_WORKSPACE")
fi

# --- Вариант B: текущая папка если есть файлы агента ---
CURRENT_IN_LIST=false
if [ -n "$OC_WORKSPACE" ] && [ "$(cd "$OC_WORKSPACE" 2>/dev/null && pwd)" = "$(pwd)" ]; then
  CURRENT_IN_LIST=true
fi

if [ "$CURRENT_IN_LIST" = false ]; then
  if [ -f "SOUL.md" ] || [ -d "skills" ] || [ -f "AGENTS.md" ] || [ -f "MEMORY.md" ] || [ -f "CLAUDE.md" ]; then
    IDX=$((IDX+1))
    echo -e "    ${CYAN}${IDX}${RESET}) 📁 ${BOLD}$(pwd)${RESET}"
    echo -e "       ${DIM}Здесь уже есть файлы агента${RESET}"
    PATHS+=("$(pwd)")
    CURRENT_IN_LIST=true
  fi
fi

# --- Вариант C: стандартный путь из гайда ---
GUIDE_WS="$HOME/openclaw-factory"
GUIDE_ADDED=false
for p in "${PATHS[@]}"; do
  if [ "$(cd "$p" 2>/dev/null && pwd)" = "$(cd "$GUIDE_WS" 2>/dev/null && pwd)" ] 2>/dev/null; then
    GUIDE_ADDED=true
  fi
done

if [ "$GUIDE_ADDED" = false ]; then
  IDX=$((IDX+1))
  if [ -d "$GUIDE_WS" ]; then
    echo -e "    ${CYAN}${IDX}${RESET}) 📁 ${BOLD}${GUIDE_WS}${RESET}"
    echo -e "       ${DIM}Стандартный путь из гайда fabrika.galson.pro${RESET}"
  else
    echo -e "    ${CYAN}${IDX}${RESET}) 📁 ${BOLD}${GUIDE_WS}${RESET}"
    echo -e "       ${DIM}Стандартный путь из гайда fabrika.galson.pro (будет создан)${RESET}"
  fi
  PATHS+=("$GUIDE_WS")
fi

# --- Вариант: вручную ---
IDX=$((IDX+1))
MANUAL_IDX=$IDX
echo -e "    ${CYAN}${MANUAL_IDX}${RESET}) ✏️  Указать путь вручную"

echo ""
if [ "$VARIANT" = "openclaw" ]; then
  echo -e "  ${DIM}💡 Если следовали гайду fabrika.galson.pro/start/openclaw-vps/ — выбирайте${RESET}"
  echo -e "  ${DIM}   стандартный путь. Если кастомная структура — укажите вручную.${RESET}"
else
  echo -e "  ${DIM}💡 Выбирай папку проекта, где будет CLAUDE.md${RESET}"
fi
echo ""

read -p "  Выбор (1-${IDX}): " DIR_CHOICE < /dev/tty

if [ "$DIR_CHOICE" = "$MANUAL_IDX" ]; then
  read -p "  Полный путь: " CUSTOM_DIR < /dev/tty
  if [ -z "$CUSTOM_DIR" ]; then
    echo -e "  ${CROSS} Путь не указан"
    exit 1
  fi
  INSTALL_DIR="${CUSTOM_DIR/#\~/$HOME}"
  mkdir -p "$INSTALL_DIR"
elif [ "$DIR_CHOICE" -ge 1 ] && [ "$DIR_CHOICE" -lt "$MANUAL_IDX" ] 2>/dev/null; then
  INSTALL_DIR="${PATHS[$((DIR_CHOICE-1))]}"
  mkdir -p "$INSTALL_DIR"
else
  echo -e "  ${CROSS} Неверный выбор"
  exit 1
fi

echo -e "\n  ${ARROW} Устанавливаю в: ${BOLD}${INSTALL_DIR}${RESET}"

# === Шаг 4: Установка ===
echo ""
echo -e "${BOLD}Шаг 3 из 7${RESET} ${DIM}— Установка${RESET}"
echo ""

echo -ne "  Скачиваю конструктор... "
TMPFILE="/tmp/content-factory-$$.tar.gz"
curl -sfL --connect-timeout 15 --max-time 180 --retry 2 "https://bot.galson.pro/api/factory/download?token=${TOKEN}&variant=${VARIANT}" -o "$TMPFILE" || true

if [ ! -s "$TMPFILE" ]; then
  echo -e "${RED}ошибка${RESET}"
  exit 1
fi
echo -e "${GREEN}ок${RESET}"

cd "$INSTALL_DIR"

# Определяем корневую папку архива автоматически
STRIP_DIR=$(tar -tzf "$TMPFILE" 2>/dev/null | head -1 | cut -d/ -f1)
if [ -z "$STRIP_DIR" ]; then
  echo -e "  ${CROSS} Ошибка: архив пустой"
  exit 1
fi

# === Скиллы ===
if [ "$VARIANT" = "openclaw" ]; then
  # OpenClaw: скиллы → ~/.openclaw/skills/ (Installed Skills в dashboard)
  SKILLS_TARGET="$HOME/.openclaw/skills"
  mkdir -p "$SKILLS_TARGET"
  EXISTING_COUNT=$(ls -d "$SKILLS_TARGET"/*/ 2>/dev/null | wc -l | tr -d ' ')
  if [ "$EXISTING_COUNT" -gt 0 ] 2>/dev/null; then
    echo -ne "  Бэкап installed skills ($EXISTING_COUNT)... "
    cp -r "$SKILLS_TARGET" "$HOME/.openclaw/skills.backup.$(date +%Y%m%d)" 2>/dev/null
    echo -e "${GREEN}ок${RESET}"
  fi
  echo -ne "  Устанавливаю скиллы в Installed Skills... "
  tar -xzf "$TMPFILE" --strip-components=2 -C "$SKILLS_TARGET" "$STRIP_DIR/skills/" 2>/dev/null || true
  SKILL_COUNT=$(ls -d "$SKILLS_TARGET"/*/ 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}${SKILL_COUNT} скиллов${RESET}"
fi

# === Workspace / Структура ===
if [ "$VARIANT" = "openclaw" ]; then
  # OpenClaw: workspace файлы из workspace/ подпапки
  echo -e "  Настраиваю workspace:"
  for f in SOUL.md AGENTS.md MEMORY.md IDENTITY.md USER.md HEARTBEAT.md BOOTSTRAP.md; do
    if [ ! -f "$f" ]; then
      tar -xzf "$TMPFILE" --strip-components=1 "$STRIP_DIR/$f" 2>/dev/null || true
      if [ -f "$f" ]; then
        echo -e "    ${GREEN}+${RESET} $f"
      fi
    else
      echo -e "    ${DIM}✓ $f (не трогаю)${RESET}"
    fi
  done

  for d in learning brand memory; do
    if [ ! -d "$d" ]; then
      if [ "$d" = "memory" ]; then
        mkdir -p "$d"
      else
        tar -xzf "$TMPFILE" --strip-components=1 "$STRIP_DIR/$d/" 2>/dev/null || true
      fi
      echo -e "    ${GREEN}+${RESET} $d/"
    else
      echo -e "    ${DIM}✓ $d/ (не трогаю)${RESET}"
    fi
  done

  # --- Config template (не перезаписываем если есть) ---
  if [ ! -f "config-template.json" ]; then
    tar -xzf "$TMPFILE" --strip-components=1 "$STRIP_DIR/config-template.json" 2>/dev/null || true
    [ -f "config-template.json" ] && echo -e "    ${GREEN}+${RESET} config-template.json"
  else
    echo -e "    ${DIM}✓ config-template.json (не трогаю)${RESET}"
  fi

  # --- SKILLS-MAP.md (всегда обновляем — системный) ---
  echo -ne "  Карта скиллов... "
  tar -xzf "$TMPFILE" --strip-components=1 "$STRIP_DIR/SKILLS-MAP.md" 2>/dev/null || true
  [ -f "SKILLS-MAP.md" ] && echo -e "${GREEN}ок${RESET}" || echo -e "${DIM}пропущено${RESET}"

fi

# === Документация (обе платформы) ===
echo -ne "  Документация... "
for f in CHANGELOG.md README.md VERSION; do
  tar -xzf "$TMPFILE" --strip-components=1 "$STRIP_DIR/$f" 2>/dev/null || true
done
echo -e "${GREEN}ок${RESET}"



# === Шаг 4.5: Создание агентов (5agents/VIP) ===
if [ "$VARIANT" = "openclaw" ] && [ "$MULTI_AGENT" = true ]; then
  echo ""
  echo -e "  ${BOLD}Настраиваю 6 агентов...${RESET}"

  # Бэкап agents/ если есть
  if [ -d "$INSTALL_DIR/agents" ] && [ "$(ls -A "$INSTALL_DIR/agents" 2>/dev/null)" ]; then
    cp -r "$INSTALL_DIR/agents" "$INSTALL_DIR/agents-backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null
    echo -e "  ${CHECK} Бэкап agents/"
  fi

  mkdir -p "$INSTALL_DIR/projects"
  API_URL="https://bot.galson.pro/api/5agents"

  for agent in coordinator copywriter marketer designer tech brain; do
    AGENT_DIR="$INSTALL_DIR/agents/$agent"
    mkdir -p "$AGENT_DIR/memory" "$AGENT_DIR/learning"

    # SOUL.md — скачиваем с VPS (не перезаписываем кастомизированный)
    SOUL_LINES=0
    [ -f "$AGENT_DIR/SOUL.md" ] && SOUL_LINES=$(wc -l < "$AGENT_DIR/SOUL.md" | tr -d " ")
    if [ "$SOUL_LINES" -lt 5 ]; then
      curl -sf "${API_URL}/soul/${agent}?token=${TOKEN}" -o "$AGENT_DIR/SOUL.md" 2>/dev/null || true
    fi

    # Шаблонные файлы — создаём только если нет
    [ ! -f "$AGENT_DIR/MEMORY.md" ] && echo "# Memory — $agent" > "$AGENT_DIR/MEMORY.md"
    [ ! -f "$AGENT_DIR/AGENTS.md" ] && { curl -sf "${API_URL}/agents/${agent}?token=${TOKEN}" -o "$AGENT_DIR/AGENTS.md" 2>/dev/null || true; }
    [ ! -f "$AGENT_DIR/USER.md" ] && printf "# USER.md\n\n- **Name:** (заполни)\n- **Timezone:** (заполни)\n- **Language:** Russian\n" > "$AGENT_DIR/USER.md"
    [ ! -f "$AGENT_DIR/IDENTITY.md" ] && printf "# IDENTITY.md — $agent\n" > "$AGENT_DIR/IDENTITY.md"
    [ ! -f "$AGENT_DIR/HEARTBEAT.md" ] && printf "# HEARTBEAT.md\n\n## Rules\n- Quiet hours: 23:00-07:00\n- If nothing to do → HEARTBEAT_OK\n" > "$AGENT_DIR/HEARTBEAT.md"
    [ ! -f "$AGENT_DIR/BOOTSTRAP.md" ] && printf "# BOOTSTRAP.md\n\n1. read SOUL.md + USER.md\n2. read memory/active-context.md\n3. read learning/corrections.md\n4. memory_search on topic\n" > "$AGENT_DIR/BOOTSTRAP.md"
    [ ! -f "$AGENT_DIR/memory/active-context.md" ] && printf "# Active Context\n\n## Last task\n(none yet)\n" > "$AGENT_DIR/memory/active-context.md"
    [ ! -f "$AGENT_DIR/learning/patterns.md" ] && echo "# Patterns" > "$AGENT_DIR/learning/patterns.md"
    [ ! -f "$AGENT_DIR/learning/anti-patterns.md" ] && echo "# Anti-patterns" > "$AGENT_DIR/learning/anti-patterns.md"
    [ ! -f "$AGENT_DIR/learning/corrections.md" ] && echo "# Corrections" > "$AGENT_DIR/learning/corrections.md"

    case $agent in
      coordinator) echo -e "    ${GOLD}🟡${RESET} Координатор" ;;
      copywriter)  echo -e "    ${GOLD}🟠${RESET} Копирайтер" ;;
      marketer)    echo -e "    ${GOLD}📈${RESET} Маркетолог" ;;
      designer)    echo -e "    ${GOLD}🟣${RESET} Дизайнер" ;;
      tech)        echo -e "    ${GOLD}🟢${RESET} Технарь" ;;
      brain)   echo -e "    ${GOLD}🧠${RESET} Архивариус" ;;
    esac
  done

  # Доп. скиллы 5agents
  echo -ne "  Скачиваю доп. скиллы... "
  SKILLS_TARGET="${HOME}/.openclaw/skills"
  mkdir -p "$SKILLS_TARGET"
  TMP5="/tmp/5agents-skills-$$.tar.gz"
  curl -sf "${API_URL}/download?token=${TOKEN}" -o "$TMP5" 2>/dev/null || true
  if [ -s "$TMP5" ]; then
    tar xzf "$TMP5" -C "$SKILLS_TARGET" 2>/dev/null
    rm -f "$TMP5"
    echo -e "${GREEN}ок${RESET}"
  else
    rm -f "$TMP5"
    echo -e "${DIM}пропущено${RESET}"
  fi

  # VIP скиллы (если VIP тариф)
  if [ "$TIER" = "vip" ]; then
    echo -ne "  Скачиваю VIP скиллы... "
    TMPVIP="/tmp/vip-skills-$$.tar.gz"
    curl -sf "https://bot.galson.pro/api/vip-factory/download?token=${TOKEN}" -o "$TMPVIP" 2>/dev/null || true
    if [ -s "$TMPVIP" ]; then
      TMPD=$(mktemp -d)
      tar xzf "$TMPVIP" -C "$TMPD" 2>/dev/null
      [ -d "$TMPD/skills" ] && cp -r "$TMPD/skills"/* "$SKILLS_TARGET/" 2>/dev/null
      rm -rf "$TMPD" "$TMPVIP"
      echo -e "${GREEN}ок${RESET}"
    else
      rm -f "$TMPVIP"
      echo -e "${DIM}пропущено${RESET}"
    fi
  fi

  TOTAL_SKILLS=$(ls -d "$SKILLS_TARGET"/*/ 2>/dev/null | wc -l | tr -d ' ')
  echo -e "  ${CHECK} 6 агентов + ${TOTAL_SKILLS} скиллов"
fi

# === Шаг 5: Подключение модели ===
if [ "$VARIANT" = "openclaw" ]; then
  echo ""
  echo -e "${BOLD}Шаг 4 из 7${RESET} ${DIM}— Подключение модели${RESET}"
  echo ""

  # Проверяем есть ли уже настроенная авторизация
  OC_CONFIG="$HOME/.openclaw/openclaw.json"
  HAS_AUTH=false
  DETECTED_PROVIDER=""
  if [ -f "$OC_CONFIG" ]; then
    grep -q '"ANTHROPIC_API_KEY"' "$OC_CONFIG" 2>/dev/null && HAS_AUTH=true && DETECTED_PROVIDER="Anthropic"
    grep -q '"OPENAI_API_KEY"' "$OC_CONFIG" 2>/dev/null && HAS_AUTH=true && DETECTED_PROVIDER="OpenAI"
    grep -q '"OPENROUTER_API_KEY"' "$OC_CONFIG" 2>/dev/null && HAS_AUTH=true && DETECTED_PROVIDER="OpenRouter"
  fi
  # Проверяем OAuth профиль
  if [ -f "$HOME/.openclaw/agents/default/agent/auth-profiles.json" ]; then
    if grep -q "anthropic" "$HOME/.openclaw/agents/default/agent/auth-profiles.json" 2>/dev/null; then
      HAS_AUTH=true
      DETECTED_PROVIDER="Claude (подписка)"
    fi
  fi

  if [ "$HAS_AUTH" = true ]; then
    echo -e "  ${CHECK} Модель уже подключена${DETECTED_PROVIDER:+ ($DETECTED_PROVIDER)}"
  else
    echo -e "  ${YELLOW}⚠${RESET}  ${BOLD}Важно:${RESET} архитектура Фабрики выстроена под модели Claude."
    echo -e "     Все скиллы, промпты и агенты оптимизированы под Claude."
    echo -e "     Другие модели могут дать совершенно другой результат."
    echo ""
    echo -e "  Выбери провайдер модели:"
    echo ""
    echo -e "    ${CYAN}1${RESET}) ${BOLD}Claude подписка${RESET} ${GREEN}(рекомендовано)${RESET}"
    echo -e "       Если есть подписка Pro (\$20) или Max (\$100/\$200)."
    echo -e "       Работает через твой план — отдельно не платишь."
    echo ""
    echo -e "    ${CYAN}2${RESET}) ${BOLD}Anthropic API ключ${RESET}"
    echo -e "       console.anthropic.com — оплата за использование."
    echo ""
    echo -e "    ${CYAN}3${RESET}) ${BOLD}OpenAI API ключ${RESET} ${YELLOW}(результат может отличаться)${RESET}"
    echo -e "       platform.openai.com — GPT-4.1 и другие модели."
    echo ""
    echo -e "    ${CYAN}4${RESET}) ${BOLD}OpenRouter API ключ${RESET} ${YELLOW}(результат может отличаться)${RESET}"
    echo -e "       openrouter.ai — доступ к 200+ моделям через один ключ."
    echo ""
    echo -e "    ${CYAN}5${RESET}) ${DIM}Пропустить (настрою позже)${RESET}"
    echo ""

    AUTH_CHOICE=""
    read -p "  Выбор (1-5): " AUTH_CHOICE < /dev/tty

    # --- Функция записи ключа в openclaw.json ---
    write_api_key() {
      local KEY_NAME="$1"
      local KEY_VALUE="$2"
      local MODEL_ID="$3"

      if [ -f "$OC_CONFIG" ]; then
        if command -v node &>/dev/null; then
          node -e "
            const fs = require('fs');
            const cfg = JSON.parse(fs.readFileSync('$OC_CONFIG', 'utf8'));
            if (!cfg.env) cfg.env = {};
            if (!cfg.env.vars) cfg.env.vars = {};
            cfg.env.vars['$KEY_NAME'] = '$KEY_VALUE';
            if ('$MODEL_ID') cfg.default_model = '$MODEL_ID';
            fs.writeFileSync('$OC_CONFIG', JSON.stringify(cfg, null, 2));
          " 2>/dev/null && return 0
        elif command -v python3 &>/dev/null; then
          python3 -c "
import json, os
p = os.path.expanduser('$OC_CONFIG')
with open(p) as f: cfg = json.load(f)
cfg.setdefault('env', {}).setdefault('vars', {})['$KEY_NAME'] = '$KEY_VALUE'
model = '$MODEL_ID'
if model: cfg['default_model'] = model
with open(p, 'w') as f: json.dump(cfg, f, indent=2)
          " 2>/dev/null && return 0
        fi
      fi
      return 1
    }

    case $AUTH_CHOICE in
      1)
        # === Токен подписки (setup-token) ===
        echo ""
        echo -e "  ${BOLD}Подключение через подписку Claude${RESET}"
        echo ""

        HAS_CLAUDE_CLI=false
        command -v claude &>/dev/null && HAS_CLAUDE_CLI=true

        if [ "$HAS_CLAUDE_CLI" = true ]; then
          echo -e "  ${CHECK} Claude Code CLI обнаружен."
          echo ""
          echo -e "  Выполни в ${BOLD}отдельном терминале${RESET}:"
          echo ""
          echo -e "    ${CYAN}claude setup-token${RESET}"
          echo ""
          echo -e "  Скопируй полученный токен и вставь сюда."
        else
          echo -e "  Для получения токена нужен Claude Code CLI."
          echo ""
          echo -e "  Выполни в ${BOLD}отдельном терминале${RESET}:"
          echo ""
          echo -e "    ${CYAN}npm install -g @anthropic-ai/claude-code${RESET}"
          echo -e "    ${CYAN}claude login${RESET}"
          echo -e "    ${CYAN}claude setup-token${RESET}"
          echo ""
          echo -e "  Скопируй полученный токен и вставь сюда."
        fi
          echo ""
          read -p "  Setup-token (или Enter — пропустить): " MANUAL_TOKEN < /dev/tty
          if [ -n "$MANUAL_TOKEN" ]; then
            if command -v openclaw &>/dev/null; then
              echo "$MANUAL_TOKEN" | openclaw models auth paste-token --provider anthropic 2>/dev/null \
                && echo -e "  ${CHECK} Токен подписки подключен" \
                || echo -e "  ${CROSS} Не удалось подключить. Выполни вручную: openclaw models auth paste-token --provider anthropic"
            else
              echo -e "  ${YELLOW}⚠${RESET}  OpenClaw CLI не найден. После установки выполни:"
              echo -e "     ${CYAN}echo \"ТОКЕН\" | openclaw models auth paste-token --provider anthropic${RESET}"
            fi
          else
            echo -e "  ${DIM}Пропущено. Подключи подписку позже:${RESET}"
            echo -e "  ${CYAN}claude setup-token${RESET}  →  ${CYAN}openclaw models auth paste-token --provider anthropic${RESET}"
          fi
        ;;

      2)
        # === Anthropic API ключ ===
        echo ""
        echo -e "  ${BOLD}Подключение Anthropic API${RESET}"
        echo ""
        echo -e "  Где взять ключ:"
        echo -e "  1. Зайди на ${BOLD}console.anthropic.com/settings/keys${RESET}"
        echo -e "  2. Нажми ${BOLD}Create Key${RESET}"
        echo -e "  3. Скопируй ключ (начинается с sk-ant-...)"
        echo ""

        while true; do
          read -p "  Anthropic API ключ: " API_KEY < /dev/tty
          if [[ "$API_KEY" == sk-* ]]; then
            echo -e "  ${CHECK} Ключ принят"
            write_api_key "ANTHROPIC_API_KEY" "$API_KEY" "" \
              && echo -e "  ${CHECK} Записано в openclaw.json" \
              || echo -e "  ${YELLOW}⚠${RESET}  Добавь вручную: openclaw.json → env.vars.ANTHROPIC_API_KEY"
            break
          elif [ -z "$API_KEY" ]; then
            echo -e "  ${CROSS} Ключ обязателен. Получи на console.anthropic.com/settings/keys"
          else
            echo -e "  ${CROSS} Ключ начинается с sk-ant-... или sk-"
          fi
        done
        ;;

      3)
        # === OpenAI API ключ ===
        echo ""
        echo -e "  ${BOLD}Подключение OpenAI API${RESET}"
        echo ""
        echo -e "  Где взять ключ:"
        echo -e "  1. Зайди на ${BOLD}platform.openai.com/api-keys${RESET}"
        echo -e "  2. Нажми ${BOLD}Create new secret key${RESET}"
        echo -e "  3. Скопируй ключ (начинается с sk-...)"
        echo ""

        while true; do
          read -p "  OpenAI API ключ: " API_KEY < /dev/tty
          if [[ "$API_KEY" == sk-* ]]; then
            echo -e "  ${CHECK} Ключ принят"
            write_api_key "OPENAI_API_KEY" "$API_KEY" "openai/gpt-4.1" \
              && echo -e "  ${CHECK} Записано в openclaw.json (модель: gpt-4.1)" \
              || echo -e "  ${YELLOW}⚠${RESET}  Добавь вручную: openclaw.json → env.vars.OPENAI_API_KEY"
            break
          elif [ -z "$API_KEY" ]; then
            echo -e "  ${CROSS} Ключ обязателен. Получи на platform.openai.com/api-keys"
          else
            echo -e "  ${CROSS} Ключ начинается с sk-..."
          fi
        done
        ;;

      4)
        # === OpenRouter API ключ ===
        echo ""
        echo -e "  ${BOLD}Подключение OpenRouter${RESET}"
        echo ""
        echo -e "  Где взять ключ:"
        echo -e "  1. Зайди на ${BOLD}openrouter.ai/keys${RESET}"
        echo -e "  2. Нажми ${BOLD}Create Key${RESET}"
        echo -e "  3. Скопируй ключ (начинается с sk-or-...)"
        echo ""
        echo -e "  ${DIM}OpenRouter даёт доступ к Claude, GPT, Gemini, Llama и 200+ моделям.${RESET}"
        echo ""

        while true; do
          read -p "  OpenRouter API ключ: " API_KEY < /dev/tty
          if [ -n "$API_KEY" ]; then
            echo -e "  ${CHECK} Ключ принят"

            # Выбор модели для OpenRouter
            echo ""
            echo -e "  Какую модель использовать по умолчанию?"
            echo ""
            echo -e "    ${CYAN}1${RESET}) Claude Sonnet 4.6 ${GREEN}(рекомендовано)${RESET}"
            echo -e "    ${CYAN}2${RESET}) GPT-4.1"
            echo -e "    ${CYAN}3${RESET}) Gemini 2.5 Pro"
            echo -e "    ${CYAN}4${RESET}) Claude Opus 4.6 ${YELLOW}(дорогая — ~\$15/M токенов)${RESET}"
            echo ""
            read -p "  Выбор (1-4): " MODEL_CHOICE < /dev/tty

            case $MODEL_CHOICE in
              1) OR_MODEL="openrouter/anthropic/claude-sonnet-4-6" ;;
              2) OR_MODEL="openrouter/openai/gpt-4.1" ;;
              3) OR_MODEL="openrouter/google/gemini-2.5-pro" ;;
              4) OR_MODEL="openrouter/anthropic/claude-opus-4-6" ;;
              *) OR_MODEL="openrouter/anthropic/claude-sonnet-4-6" ;;
            esac

            write_api_key "OPENROUTER_API_KEY" "$API_KEY" "$OR_MODEL" \
              && echo -e "  ${CHECK} Записано в openclaw.json (модель: $(echo $OR_MODEL | sed 's|openrouter/||'))" \
              || echo -e "  ${YELLOW}⚠${RESET}  Добавь вручную: openclaw.json → env.vars.OPENROUTER_API_KEY"
            break
          else
            echo -e "  ${CROSS} Ключ обязателен. Получи на openrouter.ai/keys"
          fi
        done
        ;;

      5)
        echo -e "\n  ${DIM}Пропущено. Подключи модель позже:${RESET}"
        echo -e "  ${DIM}Claude подписка: openclaw models auth setup-token --provider anthropic${RESET}"
        echo -e "  ${DIM}API ключ: openclaw.json → env.vars.ANTHROPIC_API_KEY${RESET}"
        echo -e "  ${DIM}OpenAI: openclaw.json → env.vars.OPENAI_API_KEY${RESET}"
        echo -e "  ${DIM}OpenRouter: openclaw.json → env.vars.OPENROUTER_API_KEY${RESET}"
        ;;

      *)
        echo -e "  ${DIM}Пропущено.${RESET}"
        ;;
    esac
  fi
fi

# === Шаг 6-7: Telegram бот + конфиг (только OpenClaw) ===
if [ "$VARIANT" = "openclaw" ]; then

  # === Шаг 6: Telegram бот(ы) ===
  echo ""
  echo -e "${BOLD}Шаг 5 из 7${RESET} ${DIM}— Telegram бот${RESET}"
  echo ""

  if [ "$MULTI_AGENT" = true ]; then
    # --- 5agents / VIP: 6 ботов ---
    echo -e "  Для каждого агента нужен свой Telegram бот."
    echo -e "  Создай ${BOLD}6 ботов${RESET} через ${CYAN}@BotFather${RESET} и вставь токены."
    echo ""

    TOKEN_coordinator="" TOKEN_copywriter="" TOKEN_marketer=""
    TOKEN_designer="" TOKEN_tech="" TOKEN_brain=""

    for agent in coordinator copywriter marketer designer tech brain; do
      case $agent in
        coordinator) agent_label="🟡 1. Координатор" ;;
        copywriter)  agent_label="🟠 2. Копирайтер" ;;
        marketer)    agent_label="📈 3. Маркетолог" ;;
        designer)    agent_label="🟣 4. Дизайнер" ;;
        tech)        agent_label="🟢 5. Технарь" ;;
        brain)   agent_label="🧠 6. Архивариус" ;;
      esac
      while true; do
        read -p "  ${agent_label} токен: " agent_token < /dev/tty
        if [[ "$agent_token" =~ ^[0-9]+:.+$ ]]; then
          eval "TOKEN_${agent}=\"$agent_token\""
          break
        elif [ -z "$agent_token" ]; then
          echo -e "  ${DIM}Пропущено — добавь позже${RESET}"
          break
        else
          echo -e "  ${CROSS} Формат: 123456789:ABCdef..."
        fi
      done
    done
    echo -e "  ${CHECK} Токены получены"
    BOT_TOKEN_TG="multi"  # flag for config generation
  else
    # --- Constructor: 1 бот ---
    echo -e "  Чтобы общаться с агентом через Telegram,"
    echo -e "  нужен бот. Создай его через ${CYAN}@BotFather${RESET}."
    echo ""
    echo -e "  ${DIM}1. Открой @BotFather в Telegram${RESET}"
    echo -e "  ${DIM}2. Напиши /newbot${RESET}"
    echo -e "  ${DIM}3. Придумай имя и username${RESET}"
    echo -e "  ${DIM}4. Скопируй токен (вида 123456789:ABC...)${RESET}"
    echo ""

    BOT_TOKEN_TG=""
    while true; do
      read -p "  Токен бота (или Enter — пропустить): " BOT_TOKEN_TG < /dev/tty
      if [ -z "$BOT_TOKEN_TG" ]; then
        echo -e "  ${DIM}Пропущено. Добавь позже в openclaw.json${RESET}"
        break
      elif [[ "$BOT_TOKEN_TG" =~ ^[0-9]+:.+$ ]]; then
        echo -e "  ${CHECK} Токен бота принят"
        break
      else
        echo -e "  ${CROSS} Неверный формат. Токен выглядит как: 123456789:ABCdefGHIjklMNOpqrSTUvwxyz"
      fi
    done
  fi

  # Telegram ID
  TG_USER_ID=""
  if [ -n "$BOT_TOKEN_TG" ]; then
    echo ""
    echo -e "  Твой Telegram ID (чтобы бот отвечал только тебе)"
    echo -e "  ${DIM}Напиши @userinfobot в Telegram — он покажет ID (число)${RESET}"
    echo ""
    while true; do
      read -p "  Telegram ID: " TG_USER_ID < /dev/tty
      if [[ "$TG_USER_ID" =~ ^[0-9]+$ ]]; then
        echo -e "  ${CHECK} ID: $TG_USER_ID"
        break
      elif [ -z "$TG_USER_ID" ]; then
        echo -e "  ${DIM}Пропущено. Добавь allowFrom позже.${RESET}"
        break
      else
        echo -e "  ${CROSS} ID — это число. Пример: 123456789"
      fi
    done
  fi

  # === Шаг 7: Генерация конфига ===
  echo ""
  echo -e "${BOLD}Шаг 6 из 7${RESET} ${DIM}— Конфигурация${RESET}"
  echo ""

  OC_DIR="$HOME/.openclaw"
  OC_CONFIG="$OC_DIR/openclaw.json"
  mkdir -p "$OC_DIR"
  MODEL_PRIMARY="anthropic/claude-sonnet-4-6"

  # Бэкап если есть
  BACKUP_TS=$(date +%Y%m%d%H%M%S)
  if [ -f "$OC_CONFIG" ]; then
    cp "$OC_CONFIG" "$OC_CONFIG.backup.$BACKUP_TS"
    echo -e "  ${CHECK} Бэкап конфига: openclaw.json.backup.$BACKUP_TS"
  fi

  # Детекция кастомных агентов (merge-защита)
  if [ -f "$OC_CONFIG" ] && command -v node &>/dev/null; then
    CUSTOM_FOUND=$(node -e "
      const c=JSON.parse(require('fs').readFileSync('$OC_CONFIG','utf8'));
      const std=['default','coordinator','copywriter','marketer','designer','tech','brain'];
      const custom=(c.agents?.list||[]).filter(a=>!std.includes(a.id));
      custom.forEach(a=>console.log((a.identity?.emoji||'🤖')+' '+a.id+' ('+(a.name||'?')+')'));
    " 2>/dev/null)

    if [ -n "$CUSTOM_FOUND" ]; then
      echo ""
      echo -e "  ${YELLOW}⚠️  Обнаружены ваши агенты:${RESET}"
      echo "$CUSTOM_FOUND" | while read line; do echo -e "     $line"; done
      echo ""
      echo -e "  Они ${GREEN}НЕ будут затронуты${RESET}."
      echo -e "  Обновятся только стандартные агенты."
      echo ""
      read -p "  Продолжить? (y/N): " merge_confirm < /dev/tty
      if [[ ! "$merge_confirm" =~ ^[Yy]$ ]]; then
        echo "  Отменено."
        exit 0
      fi
    fi
  fi

  # --- Универсальный Node.js merge (работает для всех тиров) ---
  echo -ne "  Генерирую конфиг... "

  # Собираем токены в JSON-формат для передачи в Node
  if [ "$MULTI_AGENT" = true ]; then
    TOKENS_JSON="{"
    for agent in coordinator copywriter marketer designer tech brain; do
      eval "t=\$TOKEN_${agent}"
      [ -n "$t" ] && TOKENS_JSON="$TOKENS_JSON\"$agent\":\"$t\","
    done
    TOKENS_JSON="${TOKENS_JSON%,}}"
  else
    TOKENS_JSON="{}"
  fi

  node -e "
const fs = require('fs');
const configPath = '$OC_CONFIG';
const multiAgent = '$MULTI_AGENT' === 'true';
const singleToken = '$BOT_TOKEN_TG';
const tgId = '$TG_USER_ID' ? parseInt('$TG_USER_ID') : null;
const installDir = '$INSTALL_DIR';
const model = '$MODEL_PRIMARY';
const tokens = $TOKENS_JSON;

const stdIds = ['coordinator','copywriter','marketer','designer','tech','brain'];
const stdNames = {coordinator:'Координатор',copywriter:'Копирайтер',marketer:'Маркетолог',designer:'Дизайнер',tech:'Технарь',brain:'Архивариус'};
const stdEmoji = {coordinator:'🟡',copywriter:'🟠',marketer:'📈',designer:'🟣',tech:'🟢',brain:'🧠'};

// Load or create
let c = {};
if (fs.existsSync(configPath)) {
  try { c = JSON.parse(fs.readFileSync(configPath, 'utf8')); } catch(e) {}
}

// === Agents defaults (set if missing) ===
c.agents = c.agents || {};
if (!c.agents.defaults) c.agents.defaults = {};
if (!c.agents.defaults.model) c.agents.defaults.model = { primary: model };
if (!c.agents.defaults.thinkingDefault) c.agents.defaults.thinkingDefault = 'high';
if (!c.agents.defaults.heartbeat) c.agents.defaults.heartbeat = { every: '1h' };
if (!c.agents.defaults.contextPruning) c.agents.defaults.contextPruning = { mode: 'cache-ttl', ttl: '6h' };
if (!c.agents.defaults.compaction) c.agents.defaults.compaction = { mode: 'safeguard', reserveTokensFloor: 20000, memoryFlush: { enabled: true, softThresholdTokens: 4000 } };
if (!c.agents.defaults.memorySearch) c.agents.defaults.memorySearch = { enabled: true, sources: ['memory'], provider: 'openai', model: 'text-embedding-3-small', query: { maxResults: 8, minScore: 0.3 } };
if (!c.session) c.session = { reset: { mode: 'daily', atHour: 4 } };
if (!c.gateway) c.gateway = { mode: 'local', port: 18789, bind: 'loopback' };
c.plugins = c.plugins || { entries: {} };
c.plugins.entries.telegram = c.plugins.entries.telegram || { enabled: true };

c.agents.list = c.agents.list || [];
c.bindings = c.bindings || [];
c.channels = c.channels || {};
c.channels.telegram = c.channels.telegram || { enabled: true, accounts: {} };
c.channels.telegram.enabled = true;
c.channels.telegram.accounts = c.channels.telegram.accounts || {};

if (multiAgent) {
  // === 5agents/VIP: 6 agents — merge, preserve custom ===
  const customAgents = c.agents.list.filter(a => !stdIds.includes(a.id) && a.id !== 'default');
  const stdList = stdIds.map(id => ({
    id, name: stdNames[id],
    workspace: installDir + '/agents/' + id,
    identity: { emoji: stdEmoji[id] }
  }));
  c.agents.list = [...stdList, ...customAgents];

  // agentToAgent
  c.tools = c.tools || {};
  c.tools.agentToAgent = c.tools.agentToAgent || {};
  c.tools.agentToAgent.enabled = true;
  const customAllow = (c.tools.agentToAgent.allow || []).filter(id => !stdIds.includes(id));
  c.tools.agentToAgent.allow = [...stdIds, ...customAllow];

  // Bindings — preserve custom
  const customBindings = c.bindings.filter(b => !stdIds.includes(b.agentId) && b.agentId !== 'default');
  const stdBindings = stdIds.map(id => ({ agentId: id, match: { channel: 'telegram', accountId: id } }));
  c.bindings = [...stdBindings, ...customBindings];

  // Telegram accounts — only update standard
  for (const id of stdIds) {
    const existingToken = c.channels.telegram.accounts[id]?.botToken;
    c.channels.telegram.accounts[id] = {
      botToken: tokens[id] || existingToken || '',
      dmPolicy: 'allowlist',
      allowFrom: tgId ? [tgId] : (c.channels.telegram.accounts[id]?.allowFrom || []),
      groupPolicy: 'open',
      groupAllowFrom: tgId ? [tgId] : [],
      groups: { '*': { requireMention: false } },
      streaming: 'partial',
      actions: { reactions: true, sendMessage: true }
    };
  }

  // Remove 'default' agent if migrating from constructor
  c.agents.list = c.agents.list.filter(a => a.id !== 'default');
  delete c.channels.telegram.accounts.default;
  c.bindings = c.bindings.filter(b => b.agentId !== 'default');

} else {
  // === Constructor: 1 default agent ===
  if (!c.agents.list.some(a => a.id === 'default')) {
    c.agents.list.push({ id: 'default', name: 'Фабрика', workspace: installDir, identity: { emoji: '🏭' } });
  }

  if (singleToken && singleToken !== 'multi') {
    c.channels.telegram.accounts.default = {
      botToken: singleToken,
      dmPolicy: 'allowlist',
      allowFrom: tgId ? [tgId] : [],
      groupPolicy: 'open',
      groupAllowFrom: tgId ? [tgId] : [],
      streaming: 'partial',
      actions: { reactions: true, sendMessage: true }
    };
    if (!c.bindings.some(b => b.agentId === 'default')) {
      c.bindings.push({ agentId: 'default', match: { channel: 'telegram', accountId: 'default' } });
    }
  }
}

fs.writeFileSync(configPath, JSON.stringify(c, null, 2));

// Report
const total = c.agents.list.length;
const custom = c.agents.list.filter(a => !stdIds.includes(a.id) && a.id !== 'default').length;
if (custom > 0) console.log(total + ' агентов (' + (total-custom) + ' стд + ' + custom + ' кастомных)');
else console.log(total + ' агент(ов)');
  " 2>/dev/null

  if [ $? -eq 0 ]; then
    RESULT=$(node -e "const c=JSON.parse(require('fs').readFileSync('$OC_CONFIG','utf8'));console.log(c.agents.list.length)" 2>/dev/null)
    echo -e "${GREEN}ок${RESET} ($RESULT агентов)"
  else
    echo -e "${RED}ошибка${RESET}"
    echo -e "  ${YELLOW}⚠${RESET} Восстанавливаю бэкап..."
    cp "$OC_CONFIG.backup.$BACKUP_TS" "$OC_CONFIG" 2>/dev/null
    exit 1
  fi

  # Валидация
  if ! node -e "JSON.parse(require('fs').readFileSync('$OC_CONFIG','utf8'))" 2>/dev/null; then
    echo -e "  ${RED}✗${RESET} JSON невалиден — восстанавливаю бэкап"
    cp "$OC_CONFIG.backup.$BACKUP_TS" "$OC_CONFIG" 2>/dev/null
    exit 1
  fi

  echo -e "  ${CHECK} Конфиг: $OC_CONFIG"
  [ -n "$BOT_TOKEN_TG" ] && echo -e "  ${CHECK} Telegram бот(ы) подключены"
  [ -n "$TG_USER_ID" ] && echo -e "  ${CHECK} Отвечает только тебе (ID: $TG_USER_ID)"
fi

# === Создание проекта ===
echo ""
echo -e "${BOLD}Шаг 7 из 7${RESET} ${DIM}— Первый проект${RESET}"
echo ""

# Проверяем есть ли уже проект
if [ "$VARIANT" = "claudecode" ]; then
  PROJECTS_DIR="$INSTALL_DIR/projects"
  EXISTING_PROJECT=$(ls -d "$PROJECTS_DIR"/*/ 2>/dev/null | grep -v '_template\|example-' | head -1)
else
  PROJECTS_DIR="$INSTALL_DIR/projects"
  EXISTING_PROJECT=""
fi

if [ -n "$EXISTING_PROJECT" ]; then
  PROJECT_NAME=$(basename "$EXISTING_PROJECT")
  echo -e "  ${CHECK} Проект уже есть: ${BOLD}$PROJECT_NAME${RESET}"
else
  echo -e "  Назови свой проект (например: ${CYAN}fitness-blog${RESET}, ${CYAN}psychologist${RESET})"
  echo -e "  ${DIM}Латиница, без пробелов. Enter = my-project${RESET}"
  echo ""
  read -p "  Имя проекта: " PROJECT_NAME < /dev/tty
  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="my-project"
  fi
  # Sanitize
  PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  [ -z "$PROJECT_NAME" ] && PROJECT_NAME="my-project"

  mkdir -p "$PROJECTS_DIR/$PROJECT_NAME"

  # OpenClaw: проект = workspace (уже настроен через SOUL.md/brand/)
    # Создаём projects/ для выходных файлов
    mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/drafts"
    mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/published"
    mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/assets"
    echo -e "  ${CHECK} Создан: ${BOLD}projects/$PROJECT_NAME/${RESET}"
    echo -e "  ${DIM}drafts/ — черновики, published/ — готовое, assets/ — медиа${RESET}"
fi

# === Токен и update.sh ===
echo "$TOKEN" > ".factory-token"
chmod 600 ".factory-token"

cat > "update.sh" << 'UPDATEEOF'
#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
UPDATE_VER="3.0"

# === Цвета ===
BOLD="\033[1m" DIM="\033[2m" RESET="\033[0m"
GREEN="\033[32m" YELLOW="\033[33m" CYAN="\033[36m" RED="\033[31m"
CHECK="${GREEN}✓${RESET}" CROSS="${RED}✗${RESET}" ARROW="${CYAN}→${RESET}"

TOKEN=$(cat ".factory-token" 2>/dev/null)
if [ -z "$TOKEN" ]; then echo -e "${CROSS} Токен не найден. Переустанови."; exit 1; fi

# Определяем вариант
if [ -f "CLAUDE.md" ]; then VARIANT="claudecode"; else VARIANT="openclaw"; fi

# === КОМАНДЫ ===
COMMAND="${1:-update}"
SKILL_NAME="${2:-}"

show_help() {
  echo ""
  echo -e "  ${BOLD}Фабрика Контента — Обновление${RESET}"
  echo ""
  echo -e "  ${CYAN}bash update.sh${RESET}              — обновить всё"
  echo -e "  ${CYAN}bash update.sh skill <имя>${RESET}  — обновить один скилл"
  echo -e "  ${CYAN}bash update.sh skills${RESET}       — список скиллов"
  echo -e "  ${CYAN}bash update.sh check${RESET}        — проверить версию"
  echo -e "  ${CYAN}bash update.sh help${RESET}         — эта справка"
  echo ""
}

get_skills_dir() {
  if [ "$VARIANT" = "openclaw" ]; then
    echo "$HOME/.openclaw/skills"
  else
    echo "$DIR/.claude/skills"
  fi
}

get_strip_dir() {
  echo "${VARIANT}-content-factory"
}

# === check: проверить версию ===
check_version() {
  echo -ne "  Проверяю версию... "
  REMOTE=$(curl -sf "https://bot.galson.pro/api/factory/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
  LOCAL=$(cat VERSION 2>/dev/null || echo "0")
  if [ "$REMOTE" = "$LOCAL" ]; then
    echo -e "${GREEN}актуально${RESET} (v${LOCAL})"
  else
    echo -e "${YELLOW}доступно обновление${RESET}: ${LOCAL} → ${REMOTE}"
  fi
}

# === skills: список установленных скиллов ===
list_skills() {
  SKILLS_DIR=$(get_skills_dir)
  echo ""
  echo -e "  ${BOLD}Установленные скиллы:${RESET}"
  echo ""
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    if [ -f "$d/SKILL.md" ]; then
      desc=$(grep -m1 '^description:' "$d/SKILL.md" 2>/dev/null | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | cut -c1-60)
      echo -e "  ${GREEN}●${RESET} ${BOLD}${name}${RESET}"
      [ -n "$desc" ] && echo -e "    ${DIM}${desc}${RESET}"
    else
      echo -e "  ${DIM}○ ${name} (нет SKILL.md)${RESET}"
    fi
  done
  echo ""
  echo -e "  ${DIM}Обновить один: bash update.sh skill <имя>${RESET}"
  echo ""
}

# === skill <name>: обновить один скилл ===
update_skill() {
  if [ -z "$SKILL_NAME" ]; then
    echo -e "  ${CROSS} Укажи имя скилла: ${CYAN}bash update.sh skill nano-banana${RESET}"
    exit 1
  fi

  SKILLS_DIR=$(get_skills_dir)
  STRIP=$(get_strip_dir)

  echo -e "  ${ARROW} Обновляю скилл: ${BOLD}${SKILL_NAME}${RESET}"

  # Скачиваем архив
  echo -ne "  Скачиваю... "
  TMPFILE="/tmp/factory-skill-$$.tar.gz"
  curl -sfL --connect-timeout 15 --max-time 180 --retry 2 "https://bot.galson.pro/api/factory/download?token=$TOKEN&variant=$VARIANT" -o "$TMPFILE" || true
  if [ ! -s "$TMPFILE" ]; then
    echo -e "${RED}ошибка${RESET}"
    exit 1
  fi
  echo -e "${GREEN}ок${RESET}"

  # Проверяем что скилл есть в архиве
  if ! tar -tzf "$TMPFILE" "${STRIP}/skills/${SKILL_NAME}/" >/dev/null 2>&1; then
    echo -e "  ${CROSS} Скилл ${BOLD}${SKILL_NAME}${RESET} не найден в текущей версии"
    echo ""
    echo -e "  ${DIM}Доступные скиллы:${RESET}"
    tar -tzf "$TMPFILE" "${STRIP}/skills/" 2>/dev/null | grep -oP "${STRIP}/skills/\K[^/]+" | sort -u | while read s; do
      echo -e "    ${GREEN}●${RESET} $s"
    done
    rm "$TMPFILE"
    exit 1
  fi

  # Бэкап текущего скилла
  if [ -d "$SKILLS_DIR/$SKILL_NAME" ]; then
    echo -ne "  Бэкап... "
    cp -r "$SKILLS_DIR/$SKILL_NAME" "$SKILLS_DIR/${SKILL_NAME}.backup.$(date +%Y%m%d%H%M%S)"
    echo -e "${GREEN}ок${RESET}"
  fi

  # Извлекаем только этот скилл
  echo -ne "  Устанавливаю... "
  mkdir -p "$SKILLS_DIR/$SKILL_NAME"
  # Очищаем старые файлы скилла
  rm -rf "$SKILLS_DIR/$SKILL_NAME"/*
  tar -xzf "$TMPFILE" --strip-components=2 -C "$SKILLS_DIR" "$STRIP/skills/$SKILL_NAME/" 2>/dev/null

  FILE_COUNT=$(find "$SKILLS_DIR/$SKILL_NAME" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}ок${RESET} (${FILE_COUNT} файлов)"

  rm "$TMPFILE"
  echo ""
  echo -e "  ${CHECK} Скилл ${BOLD}${SKILL_NAME}${RESET} обновлён"
  echo ""
}

# === update: полное обновление (старое поведение) ===
full_update() {
  echo -e "  ${ARROW} Полное обновление ($VARIANT)..."

  REMOTE=$(curl -sf "https://bot.galson.pro/api/factory/version" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
  LOCAL=$(cat VERSION 2>/dev/null || echo "0")

  if [ "$REMOTE" = "$LOCAL" ] && [ "$1" != "--force" ]; then
    echo -e "  ${CHECK} Актуальная версия: ${LOCAL}"
    exit 0
  fi

  echo -e "  📥 Обновляю ${LOCAL} → ${REMOTE}..."

  TMPFILE="/tmp/factory-update-$$.tar.gz"
  curl -sfL --connect-timeout 15 --max-time 180 --retry 2 "https://bot.galson.pro/api/factory/download?token=$TOKEN&variant=$VARIANT" -o "$TMPFILE" || true
  if [ ! -s "$TMPFILE" ]; then echo -e "  ${CROSS} Ошибка. Проверь токен."; exit 1; fi

  STRIP=$(get_strip_dir)
  SKILLS_DIR=$(get_skills_dir)

  # Самообновление update.sh
  NEW_UPDATE="/tmp/factory-new-update-$$.sh"
  curl -sf "https://bot.galson.pro/api/factory/update-script?variant=$VARIANT" -o "$NEW_UPDATE" 2>/dev/null || true
  if [ -s "$NEW_UPDATE" ]; then
    THEIR_VER=$(grep '^UPDATE_VER=' "$NEW_UPDATE" 2>/dev/null | cut -d'"' -f2)
    if [ -n "$THEIR_VER" ] && [ "$THEIR_VER" != "$UPDATE_VER" ]; then
      echo -e "  🔧 Обновляю update.sh (${UPDATE_VER} → ${THEIR_VER})..."
      cp "$NEW_UPDATE" "$DIR/update.sh"
      chmod +x "$DIR/update.sh"
      rm "$NEW_UPDATE"
      exec "$DIR/update.sh" "$@"
    fi
  fi
  rm -f "$NEW_UPDATE"

  # Скиллы
  echo -ne "  Скиллы... "
  mkdir -p "$SKILLS_DIR"
  cp -r "$SKILLS_DIR" "${SKILLS_DIR}.backup.$(date +%Y%m%d)" 2>/dev/null || true
  tar -xzf "$TMPFILE" --strip-components=2 -C "$SKILLS_DIR" "$STRIP/skills/" 2>/dev/null || true
  SKILL_COUNT=$(ls -d "$SKILLS_DIR"/*/ 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}${SKILL_COUNT} скиллов${RESET}"

  # Документация
  echo -ne "  Документация... "
  for f in VERSION CHANGELOG.md MEMORY-SETUP.md GETTING-STARTED.md README.md UPDATE-GUIDE.md TECHNICAL.md RESOURCES.md QUICK-START.md START.md SETUP.md VPS-INSTALL.md SKILLS-MAP.md; do
    tar -xzf "$TMPFILE" --strip-components=1 "$STRIP/$f" 2>/dev/null || true
  done
  echo -e "${GREEN}ок${RESET}"

  rm "$TMPFILE"
  echo ""
  echo -e "  ${CHECK} Обновлено до ${BOLD}v${REMOTE}${RESET} (${SKILL_COUNT} скиллов)"
  echo ""
}

# === Роутер команд ===
case "$COMMAND" in
  help|--help|-h)
    show_help
    ;;
  check)
    check_version
    ;;
  skills|list)
    list_skills
    ;;
  skill)
    update_skill
    ;;
  update|"")
    full_update "$2"
    ;;
  --force)
    full_update "--force"
    ;;
  *)
    echo -e "  ${CROSS} Неизвестная команда: ${COMMAND}"
    show_help
    exit 1
    ;;
esac
UPDATEEOF
chmod +x "update.sh"

rm "$TMPFILE"

# === Factory CLI ===

echo ""
echo -e "  Устанавливаю команду ${BOLD}factory${RESET}..."

FACTORY_CLI="${INSTALL_DIR}/factory.js"
curl -sf --connect-timeout 10 --max-time 30 "https://bot.galson.pro/factory.js" -o "${FACTORY_CLI}" 2>/dev/null || true

if [ -f "${FACTORY_CLI}" ]; then
    chmod +x "${FACTORY_CLI}"
    if [ -w /usr/local/bin ]; then
        ln -sf "${FACTORY_CLI}" /usr/local/bin/factory
    elif [ -d "$HOME/.local/bin" ]; then
        ln -sf "${FACTORY_CLI}" "$HOME/.local/bin/factory"
    else
        mkdir -p "$HOME/.local/bin"
        ln -sf "${FACTORY_CLI}" "$HOME/.local/bin/factory"
        echo -e "  ${YELLOW}⚠${RESET} Добавь в PATH: ${BOLD}export PATH="$HOME/.local/bin:$PATH"${RESET}"
    fi
    echo -e "  ${CHECK} Команда ${BOLD}factory${RESET} установлена"
else
    echo -e "  ${YELLOW}⚠${RESET} factory CLI не загрузился (можно установить позже)"
fi

# === Финал ===
echo ""
echo -e "${GOLD}  ╔══════════════════════════════════════╗${RESET}"
echo -e "${GOLD}  ║                                      ║${RESET}"
echo -e "${GOLD}  ║   ✅ Установка завершена!             ║${RESET}"
echo -e "${GOLD}  ║                                      ║${RESET}"
echo -e "${GOLD}  ╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}Фабрика Контента${RESET} v${VERSION}"
echo -e "  📁 Workspace: ${INSTALL_DIR}"
echo -e "  🧩 ${SKILL_COUNT} скиллов → ${SKILLS_TARGET}"
echo ""
echo -e "  ${BOLD}Что дальше:${RESET}"
echo -e "  ${ARROW} Инструкция отправлена тебе в бот ${CYAN}@galsonproAIbot${RESET}"
echo -e "  ${ARROW} Или скажи агенту: ${CYAN}\"Я установил конструктор, что дальше?\"${RESET}"
echo -e "  ${ARROW} Обновление: ${CYAN}cd ${INSTALL_DIR} && bash update.sh${RESET}"
  echo -e "  ${ARROW} Настройки: ${CYAN}factory${RESET} (в терминале)"
if [ "$VARIANT" = "openclaw" ]; then
  echo -e "  ${ARROW} Скиллы видны в dashboard → ${CYAN}Skills → Installed Skills${RESET}"
fi
echo ""
echo -e "  ${DIM}Поддержка: @galsonproAIbot${RESET}"

# Отправляем Getting Started через бота
curl -sf -X POST "https://bot.galson.pro/api/factory/onboarding?token=${TOKEN}&variant=${VARIANT}" >/dev/null 2>&1 &
echo ""
