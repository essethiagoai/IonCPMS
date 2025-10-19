#!/bin/bash

# Script para instalar pré-requisitos do CitrineOS
# Execute este script no Terminal

echo "🚀 Instalando pré-requisitos para Íon CPMS..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}📋 Instalando pré-requisitos...${NC}"

# 1. Instalar Homebrew (se não estiver instalado)
if ! command_exists brew; then
    echo -e "${YELLOW}📦 Instalando Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Adicionar Homebrew ao PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    if command_exists brew; then
        echo -e "${GREEN}✅ Homebrew instalado com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro na instalação do Homebrew${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Homebrew já está instalado${NC}"
fi

# 2. Instalar Node.js
if ! command_exists node; then
    echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
    brew install node
    
    if command_exists node; then
        echo -e "${GREEN}✅ Node.js instalado com sucesso!${NC}"
        echo -e "${BLUE}   Versão: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Erro na instalação do Node.js${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Node.js já está instalado - $(node --version)${NC}"
fi

# 3. Verificar versão do Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ge 18 ]; then
    echo -e "${GREEN}✅ Node.js versão $(node --version) - OK${NC}"
else
    echo -e "${RED}❌ Node.js versão $(node --version) - Requer versão 18 ou superior${NC}"
    echo -e "${YELLOW}   Atualizando Node.js...${NC}"
    brew upgrade node
fi

# 4. Instalar wscat (ferramenta para testar WebSocket)
if ! command_exists wscat; then
    echo -e "${YELLOW}📦 Instalando wscat...${NC}"
    npm install -g wscat
    echo -e "${GREEN}✅ wscat instalado com sucesso!${NC}"
else
    echo -e "${GREEN}✅ wscat já está instalado${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Todos os pré-requisitos foram instalados!${NC}"
echo ""
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo -e "1. Instale o Docker Desktop: https://www.docker.com/products/docker-desktop/"
echo -e "2. Inicie o Docker Desktop"
echo -e "3. Execute: ${GREEN}./setup-citrineos.sh${NC}"
echo ""
echo -e "${YELLOW}💡 Se você já tem o Docker Desktop instalado, pode executar o setup agora!${NC}"

