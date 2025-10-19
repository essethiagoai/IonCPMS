#!/bin/bash

# Script para instalar Docker Desktop via Homebrew
# Execute este script no Terminal

echo "🐳 Instalando Docker Desktop para Íon CPMS..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se Homebrew está instalado
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew não encontrado. Instale primeiro.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Instalando Docker Desktop via Homebrew...${NC}"

# Instalar Docker Desktop
brew install --cask docker-desktop

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker Desktop instalado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}🚀 Próximos passos:${NC}"
    echo -e "1. Abra o Docker Desktop: ${GREEN}open -a Docker${NC}"
    echo -e "2. Aguarde a inicialização (pode levar alguns minutos)"
    echo -e "3. Execute: ${GREEN}./setup-citrineos.sh${NC}"
    echo ""
    echo -e "${BLUE}💡 Para abrir o Docker Desktop automaticamente:${NC}"
    echo -e "   ${GREEN}open -a Docker${NC}"
else
    echo -e "${RED}❌ Erro na instalação do Docker Desktop${NC}"
    echo -e "${YELLOW}💡 Tente instalar manualmente:${NC}"
    echo -e "   1. Acesse: https://www.docker.com/products/docker-desktop/"
    echo -e "   2. Baixe o Docker Desktop para Mac"
    echo -e "   3. Instale o arquivo .dmg"
fi
