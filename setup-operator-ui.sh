#!/bin/bash

# Script para instalar e configurar a Operator UI do CitrineOS
# Execute este script no Terminal

echo "🎨 Instalando Operator UI do CitrineOS para Íon CPMS..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar se estamos no diretório correto
if [ ! -d "citrineos-core" ]; then
    echo -e "${RED}❌ Diretório citrineos-core não encontrado. Execute o setup principal primeiro.${NC}"
    exit 1
fi

# Verificar se Node.js está instalado
if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ Node.js não encontrado. Instale primeiro.${NC}"
    exit 1
fi

echo -e "${BLUE}📥 Clonando Operator UI...${NC}"

# Clonar repositório da Operator UI
if [ -d "citrineos-operator-ui" ]; then
    echo -e "${YELLOW}⚠️  Diretório citrineos-operator-ui já existe. Removendo...${NC}"
    rm -rf citrineos-operator-ui
fi

git clone https://github.com/citrineos/citrineos-operator-ui.git
echo -e "${GREEN}✅ Operator UI clonada com sucesso!${NC}"

# Navegar para o diretório
cd citrineos-operator-ui

echo -e "${BLUE}📦 Instalando dependências...${NC}"

# Instalar dependências
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dependências instaladas com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro na instalação das dependências${NC}"
    exit 1
fi

# Criar arquivo de configuração .env
echo -e "${BLUE}⚙️  Configurando variáveis de ambiente...${NC}"

cat > .env << EOF
# CitrineOS Operator UI Configuration
REACT_APP_API_URL=http://localhost:8080
REACT_APP_WS_URL=ws://localhost:8081
REACT_APP_WS_SECURE_URL=wss://localhost:8082
REACT_APP_HASURA_URL=http://localhost:8080/v1/graphql
REACT_APP_HASURA_WS_URL=ws://localhost:8080/v1/graphql
EOF

echo -e "${GREEN}✅ Arquivo .env criado com sucesso!${NC}"

echo ""
echo -e "${GREEN}🎉 Operator UI configurada com sucesso!${NC}"
echo ""
echo -e "${BLUE}📋 Para iniciar a Operator UI:${NC}"
echo -e "1. Navegue para o diretório: ${GREEN}cd citrineos-operator-ui${NC}"
echo -e "2. Inicie a aplicação: ${GREEN}npm run dev${NC}"
echo -e "3. Acesse no navegador: ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}💡 A Operator UI será iniciada automaticamente em uma nova aba do navegador.${NC}"
echo -e "${YELLOW}💡 Certifique-se de que o CitrineOS está rodando (./check-services.sh)${NC}"
echo ""
echo -e "${BLUE}🚀 Iniciando Operator UI automaticamente...${NC}"

# Iniciar a aplicação em modo de desenvolvimento
npm run dev
