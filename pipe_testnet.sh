#!/bin/bash

# Цвета
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

# Установка утилит
sudo apt update -y && sudo apt install -y figlet whiptail curl screen wget

# Приветствие
echo -e "${PINK}$(figlet -w 150 -f standard "Softs by Gentleman")${NC}"
echo "============================================================================================================================="
echo "Добро пожаловать! Пока идёт установка, подпишись на мой Telegram-канал:"
echo ""
echo "The Gentleman — https://t.me/GentleChron"
echo "============================================================================================================================="
echo ""

# Анимация
animate_loading() {
  for ((i = 1; i <= 3; i++)); do
    printf "\r${GREEN}Подгружаем меню${NC}."
    sleep 0.3
    printf "\r${GREEN}Подгружаем меню${NC}.."
    sleep 0.3
    printf "\r${GREEN}Подгружаем меню${NC}..."
    sleep 0.3
  done
  echo ""
}

install_node() {
  echo -e "${BLUE}Начинаем установку POP Node...${NC}"

  INVITE=$(whiptail --inputbox "Введите ваш invite code:" 10 60 --title "Invite Code" 3>&1 1>&2 2>&3)
  SOLANA=$(whiptail --inputbox "Введите ваш Solana-адрес:" 10 60 --title "Solana" 3>&1 1>&2 2>&3)
  RAM=$(whiptail --inputbox "Сколько RAM (в ГБ) выделить под кэш?" 10 60 --title "RAM" 3>&1 1>&2 2>&3)
  DISK=$(whiptail --inputbox "Сколько диска (в ГБ) выделить под кэш?" 10 60 --title "Disk" 3>&1 1>&2 2>&3)

  NAME=$(whiptail --inputbox "Имя вашей ноды:" 10 60 --title "Node name" 3>&1 1>&2 2>&3)
  EMAIL=$(whiptail --inputbox "Введите Email:" 10 60 --title "Email" 3>&1 1>&2 2>&3)
  SITE=$(whiptail --inputbox "Ваш сайт (https://...):" 10 60 --title "Website" 3>&1 1>&2 2>&3)
  TG=$(whiptail --inputbox "Ваш Telegram (@...):" 10 60 --title "Telegram" 3>&1 1>&2 2>&3)
  DISCORD=$(whiptail --inputbox "Discord (name#0000):" 10 60 --title "Discord" 3>&1 1>&2 2>&3)
  TWITTER=$(whiptail --inputbox "Twitter (@...):" 10 60 --title "Twitter" 3>&1 1>&2 2>&3)

  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    BIN_URL="https://dl.pipecdn.app/v0.2.8/pop"
  elif [[ "$ARCH" == "aarch64" ]]; then
    BIN_URL="https://dl.pipecdn.app/v0.2.8/pop-arm64"
  else
    echo -e "${RED}❌ Неизвестная архитектура: $ARCH. Установка прервана.${NC}"
    exit 1
  fi

  mkdir -p ~/pipe/download_cache
  cd ~/pipe || exit

  wget -O pop "$BIN_URL"
  chmod +x pop

  echo -e "${CYAN}Создаем config.json...${NC}"
  cat > config.json <<EOF
{
  "pop_name": "$NAME",
  "pop_location": "Earth, Internet",
  "invite_code": "$INVITE",
  "server": {
    "host": "0.0.0.0",
    "port": 443,
    "http_port": 80,
    "workers": 0
  },
  "cache_config": {
    "memory_cache_size_mb": $((RAM * 1024)),
    "disk_cache_path": "./download_cache",
    "disk_cache_size_gb": $DISK,
    "default_ttl_seconds": 86400,
    "respect_origin_headers": true,
    "max_cacheable_size_mb": 1024
  },
  "api_endpoints": {
    "base_url": "https://dataplane.pipenetwork.com"
  },
  "identity_config": {
    "node_name": "$NAME",
    "name": "$NAME",
    "email": "$EMAIL",
    "website": "$SITE",
    "twitter": "$TWITTER",
    "discord": "$DISCORD",
    "telegram": "$TG",
    "solana_pubkey": "$SOLANA"
  }
}
EOF

  echo -e "${GREEN}Запускаем pop через screen с POP_CONFIG_PATH...${NC}"
  screen -S popnode -dm bash -c 'export POP_CONFIG_PATH=~/pipe/config.json && ./pop'

  echo -e "${GREEN}✅ Нода установлена и запущена в screen-сессии 'popnode'.${NC}"
}

check_status() {
  echo -e "${CYAN}Проверка статуса POP Node:${NC}"
  screen -ls | grep popnode && echo -e "${GREEN}Нода запущена.${NC}" || echo -e "${RED}Нода не запущена.${NC}"
}

remove_node() {
  echo -e "${RED}Удаляем ноду...${NC}"
  screen -S popnode -X quit || true
  pkill -f pop || true
  rm -rf ~/pipe
  echo -e "${GREEN}✅ Удалено!${NC}"
}

update_node() {
  echo -e "${BLUE}Обновляем POP Node...${NC}"
  screen -S popnode -X quit || true
  pkill -f pop || true
  cd ~/pipe || exit
  rm -f pop
  wget -O pop https://dl.pipecdn.app/v0.2.8/pop
  chmod +x pop
  screen -S popnode -dm bash -c 'export POP_CONFIG_PATH=~/pipe/config.json && ./pop'
  echo -e "${GREEN}✅ Обновлено и перезапущено!${NC}"
}

animate_loading
CHOICE=$(whiptail --title "PIPE Node Установщик" \
  --menu "Выберите действие:" 15 60 6 \
  "1" "Установить POP Node" \
  "2" "Проверить статус" \
  "3" "Удалить ноду" \
  "4" "Обновить POP" \
  "5" "Выход" \
  3>&1 1>&2 2>&3)

case $CHOICE in
  1) install_node ;;
  2) check_status ;;
  3) remove_node ;;
  4) update_node ;;
  5) echo -e "${CYAN}Выход.${NC}" ;;
  *) echo -e "${RED}Неверный выбор.${NC}" ;;
esac
