#!/bin/bash

# Script de Setup do CitrineOS para Íon CPMS
# Este script automatiza a instalação e configuração do CitrineOS

set -e  # Para o script se houver erro

echo "🚀 Iniciando setup do CitrineOS para Íon CPMS..."

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

# Função para verificar versão do Node.js
check_node_version() {
    if command_exists node; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            echo -e "${GREEN}✅ Node.js versão $(node --version) - OK${NC}"
            return 0
        else
            echo -e "${RED}❌ Node.js versão $(node --version) - Requer versão 18 ou superior${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Node.js não encontrado${NC}"
        return 1
    fi
}

# Verificar pré-requisitos
echo -e "${BLUE}🔍 Verificando pré-requisitos...${NC}"

# Verificar Git
if command_exists git; then
    echo -e "${GREEN}✅ Git $(git --version) - OK${NC}"
else
    echo -e "${RED}❌ Git não encontrado. Instale o Xcode Command Line Tools primeiro.${NC}"
    exit 1
fi

# Verificar Node.js
if ! check_node_version; then
    echo -e "${YELLOW}⚠️  Instale o Node.js versão 18+ antes de continuar${NC}"
    exit 1
fi

# Verificar npm
if command_exists npm; then
    echo -e "${GREEN}✅ npm $(npm --version) - OK${NC}"
else
    echo -e "${RED}❌ npm não encontrado${NC}"
    exit 1
fi

# Verificar Docker
if command_exists docker; then
    echo -e "${GREEN}✅ Docker $(docker --version) - OK${NC}"
    
    # Verificar se Docker está rodando
    if docker info >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker está rodando - OK${NC}"
    else
        echo -e "${YELLOW}⚠️  Docker não está rodando. Inicie o Docker Desktop.${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Docker não encontrado. Instale o Docker Desktop.${NC}"
    exit 1
fi

# Verificar Docker Compose
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker Compose - OK${NC}"
else
    echo -e "${RED}❌ Docker Compose não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Todos os pré-requisitos estão OK!${NC}"

# Clonar repositório CitrineOS
echo -e "${BLUE}📥 Clonando repositório CitrineOS...${NC}"

if [ -d "citrineos-core" ]; then
    echo -e "${YELLOW}⚠️  Diretório citrineos-core já existe. Removendo...${NC}"
    rm -rf citrineos-core
fi

git clone https://github.com/citrineos/citrineos-core.git
echo -e "${GREEN}✅ Repositório clonado com sucesso!${NC}"

# Navegar para o diretório Server
cd citrineos-core/Server

# Verificar se docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Arquivo docker-compose.yml não encontrado em citrineos-core/Server${NC}"
    exit 1
fi

echo -e "${BLUE}🐳 Iniciando serviços do CitrineOS...${NC}"

# Iniciar serviços com Docker Compose
docker compose up -d

echo -e "${GREEN}🎉 CitrineOS iniciado com sucesso!${NC}"
echo ""
echo -e "${BLUE}📋 Serviços disponíveis:${NC}"
echo -e "  • Citrine OCPP HTTP Server: ${GREEN}http://localhost:8080${NC}"
echo -e "  • Documentação API: ${GREEN}http://localhost:8080/docs${NC}"
echo -e "  • OCPP WebSocket (Não Seguro): ${GREEN}ws://localhost:8081${NC}"
echo -e "  • OCPP WebSocket (Seguro): ${GREEN}wss://localhost:8082${NC}"
echo -e "  • PostgreSQL: ${GREEN}postgresql://citrine:citrine@localhost:5432/citrine${NC}"
echo -e "  • RabbitMQ: ${GREEN}amqp://guest:guest@localhost:5672${NC}"
echo ""
echo -e "${YELLOW}💡 Para parar os serviços, execute: docker compose down${NC}"
echo -e "${YELLOW}💡 Para ver logs, execute: docker compose logs -f${NC}"
echo ""
echo -e "${GREEN}🚀 Setup concluído! Acesse http://localhost:8080/docs para começar.${NC}"
