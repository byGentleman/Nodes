#!/bin/bash

# Цвета
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

INSTALL_DIR="$HOME/popnode"
CACHE_DIR="$INSTALL_DIR/download_cache"
BIN_PATH="$INSTALL_DIR/pop"
SERVICE_NAME="popnode"
BIN_URL="https://dl.pipecdn.app/v0.2.8/pop"

# Приветствие
if ! command -v figlet &> /dev/null; then
    sudo apt install -y figlet
fi
clear
echo -e "${PINK}$(figlet -w 150 -f standard "Softs by The Gentleman")${NC}"
echo "================================================================================================================"
echo "Добро пожаловать! Устанавливаем Pipe POP Node. Подписывайся на Telegram: https://t.me/GentleChron"
echo "================================================================================================================"

animate_loading() {
    for ((i = 1; i <= 3; i++)); do
        printf "\r${GREEN}Подгружаем меню${NC}."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}.."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}..."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}   "
        sleep 0.3
    done
    echo ""
}

install_node() {
    echo -e "${GREEN}Обновляем систему и устанавливаем зависимости...${NC}"
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y curl bc

    echo -e "${CYAN}Проверка версии Ubuntu...${NC}"
    UBUNTU_VERSION=$(lsb_release -rs)
    if (( $(echo "$UBUNTU_VERSION < 22.04" | bc -l) )); then
        echo -e "${RED}❌ Требуется Ubuntu 22.04 или новее.${NC}"
        exit 1
    fi

    mkdir -p "$CACHE_DIR"

    # Ввод данных через whiptail
    INVITE=$(whiptail --inputbox "Введите ваш invite-код:" 10 60 --title "Invite Code" 3>&1 1>&2 2>&3)
    NODENAME=$(whiptail --inputbox "Имя ноды (уникальное):" 10 60 "gentle-pop" --title "Node Name" 3>&1 1>&2 2>&3)
    USERNAME=$(whiptail --inputbox "Ваше имя или ник:" 10 60 --title "Имя / Ник" 3>&1 1>&2 2>&3)
    TG=$(whiptail --inputbox "Telegram (без @):" 10 60 --title "Telegram" 3>&1 1>&2 2>&3)
    DISCORD=$(whiptail --inputbox "Discord username:" 10 60 --title "Discord" 3>&1 1>&2 2>&3)
    WEBSITE=$(whiptail --inputbox "Сайт / GitHub / Twitter:" 10 60 "https://your-site.com" --title "Website" 3>&1 1>&2 2>&3)
    EMAIL=$(whiptail --inputbox "Email:" 10 60 --title "Email" 3>&1 1>&2 2>&3)
    PUBKEY=$(whiptail --inputbox "Solana адрес:" 10 60 --title "Solana PubKey" 3>&1 1>&2 2>&3)
    RAM=$(whiptail --inputbox "Оперативная память в ГБ (например, 8):" 10 60 "8" --title "RAM" 3>&1 1>&2 2>&3)
    DISK=$(whiptail --inputbox "Размер кеша на диске в ГБ (например, 100):" 10 60 "100" --title "Disk Cache" 3>&1 1>&2 2>&3)

    echo -e "${GREEN}Скачиваем бинарник...${NC}"
    curl -L -o "$BIN_PATH" "$BIN_URL"
    chmod +x "$BIN_PATH"
    "$BIN_PATH" --refresh

    echo -e "${GREEN}Создаем systemd-сервис...${NC}"
    CURRENT_USER=$(whoami)
    cat | sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=Pipe POP Node by The Gentleman
After=network.target

[Service]
User=$CURRENT_USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$BIN_PATH \\
  --invite $INVITE \\
  --name "$NODENAME" \\
  --userName "$USERNAME" \\
  --telegram "$TG" \\
  --discord "$DISCORD" \\
  --website "$WEBSITE" \\
  --email "$EMAIL" \\
  --pubKey "$PUBKEY" \\
  --ram $RAM \\
  --max-disk $DISK \\
  --cache-dir "$CACHE_DIR"
Restart=always
RestartSec=5
LimitNOFILE=65535
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME

    echo -e "${GREEN}Нода установлена и запущена.${NC}"
    echo -e "${YELLOW}Проверка логов:${NC}"
    echo -e "${CYAN}sudo journalctl -u $SERVICE_NAME -f --no-hostname -o cat${NC}"
}

remove_node() {
    echo -e "${RED}Удаляем ноду...${NC}"
    sudo systemctl stop $SERVICE_NAME
    sudo systemctl disable $SERVICE_NAME
    sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
    sudo systemctl daemon-reload
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}Нода удалена.${NC}"
}

check_status() {
    echo -e "${BLUE}Статус сервиса:${NC}"
    systemctl status $SERVICE_NAME --no-pager
}

# Главное меню
animate_loading
CHOICE=$(whiptail --title "PIPE Node Установщик" \
    --menu "Выберите действие:" 16 60 6 \
    "1" "Установить POP Cache Node" \
    "2" "Проверить статус" \
    "3" "Удалить ноду" \
    "4" "Выход" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1)
        install_node
        ;;
    2)
        check_status
        ;;
    3)
        remove_node
        ;;
    4)
        echo -e "${CYAN}Выход.${NC}"
        ;;
    *)
        echo -e "${RED}Неверный выбор.${NC}"
        ;;
esac
