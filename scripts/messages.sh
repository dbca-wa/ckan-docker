#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

success() {
    echo -e "${GREEN} [√] ${1}${NC}"
}

info() {
    echo -e "${YELLOW} [-] ${1}${NC}"
}

error() {
    echo -e "\n${RED} [x] ${1}${NC}"
}
