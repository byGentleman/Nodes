#!/bin/bash

# Цвета
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

# Проверка и установка утилит
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y figlet whiptail curl screen wget

# Приветствие
echo -e "${PINK}$(figlet -w 150 -f standard "Softs by Gentleman")${NC}"
echo -e "${PINK}$(figlet -w 150 -f standard "x WESNA")${NC}"
echo "===================================================================================================================================="
echo "Добро пожаловать! Начинаем установку необходимых библиотек, пока подпишись на наши Telegram-каналы для обновлений и поддержки:"
echo ""
echo "Gentleman - https://t.me/GentleChron"
echo "Wesna     - https://t.me/softs_by_wesna"
echo "===================================================================================================================================="
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

  # Запрашиваем данные
  INVITE=$(whiptail --inputbox "Введите ваш invite code:" 10 60 --title "Invite Code" 3>&1 1>&2 2>&3)
  SOLANA=$(whiptail --inputbox "Введите ваш публичный Solana-адрес:" 10 60 --title "Solana Address" 3>&1 1>&2 2>&3)
  RAM=$(whiptail --inputbox "Сколько RAM (в ГБ) выделить под кэш?" 10 60 --title "RAM" 3>&1 1>&2 2>&3)
  DISK=$(whiptail --inputbox "Сколько диска (в ГБ) выделить под кэш?" 10 60 --title "Disk" 3>&1 1>&2 2>&3)

  # Определяем архитектуру
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    BIN_URL="https://dl.pipecdn.app/v0.2.8/pop"
  elif [[ "$ARCH" == "aarch64" ]]; then
    BIN_URL="https://dl.pipecdn.app/v0.2.8/pop-arm64"
  else
    echo -e "${RED}❌ Неизвестная архитектура: $ARCH. Установка прервана.${NC}"
    exit 1
  fi

  # Создаем директорию
  mkdir -p ~/pipe/download_cache
  cd ~/pipe

  # Скачиваем бинарник
  wget -O pop "$BIN_URL"
  chmod +x pop

  echo -e "${GREEN}Запускаем pop через screen...${NC}"
  screen -S popnode -dm bash -c "./pop --ram $RAM --max-disk $DISK --cache-dir ~/pipe/download_cache --pubKey $SOLANA --invite-code $INVITE"

  echo -e "${GREEN}✅ Установка завершена. Нода работает в screen-сессии 'popnode'.${NC}"
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
  echo -e "${BLUE}Обновляем POP Node до последней версии...${NC}"
  screen -S popnode -X quit || true
  pkill -f pop || true
  cd ~/pipe || exit
  rm -f pop
  wget -O pop https://dl.pipecdn.app/v0.2.8/pop
  chmod +x pop
  echo -e "${GREEN}✅ Обновлено. Перезапустите вручную или из меню.${NC}"
}

# Главное меню
animate_loading
CHOICE=$(whiptail --title "PIPE Node Установщик" \
  --menu "Выберите действие:" 15 60 6 \
  "1" "Установить ноду" \
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
