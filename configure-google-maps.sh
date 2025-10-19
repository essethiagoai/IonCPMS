#!/bin/bash

# Script para configurar a API key do Google Maps no CitrineOS
# Uso: ./configure-google-maps.sh "sua_api_key_aqui"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -ne 1 ]; then
    echo -e "${RED}❌ Uso: $0 \"sua_api_key_aqui\"${NC}"
    echo -e "${YELLOW}Exemplo: $0 \"AIzaSyBvOkBw7uE4XrDdYfG8hI9jK2lM3nO5pQ7s\"${NC}"
    echo ""
    echo -e "${BLUE}📋 Para obter uma API key:${NC}"
    echo -e "1. Acesse: https://console.cloud.google.com/"
    echo -e "2. Crie um projeto ou selecione um existente"
    echo -e "3. Habilite: Maps JavaScript API, Geocoding API"
    echo -e "4. Crie uma API key em: APIs & Services → Credentials"
    echo -e "5. Configure restrições (recomendado)"
    exit 1
fi

API_KEY="$1"

echo -e "${BLUE}🗺️  Configurando Google Maps API Key...${NC}"

# Verificar se a API key parece válida (começa com AIza e tem ~39 caracteres)
if [[ ! "$API_KEY" =~ ^AIza[0-9A-Za-z_-]{35}$ ]]; then
    echo -e "${YELLOW}⚠️  A API key não parece ter o formato correto${NC}"
    echo -e "${YELLOW}   Deve começar com 'AIza' e ter ~39 caracteres${NC}"
    echo -e "${YELLOW}   Continuando mesmo assim...${NC}"
fi

# Verificar se o arquivo .env existe
ENV_FILE="citrineos-operator-ui/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}❌ Arquivo $ENV_FILE não encontrado${NC}"
    exit 1
fi

# Atualizar a API key no arquivo .env
sed -i '' "s/VITE_GOOGLE_MAPS_API_KEY=.*/VITE_GOOGLE_MAPS_API_KEY=$API_KEY/" "$ENV_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ API key configurada com sucesso!${NC}"
    echo -e "${BLUE}📝 API Key: ${API_KEY:0:10}...${NC}"
    echo ""
    echo -e "${YELLOW}🔄 Reiniciando servidor da Operator UI...${NC}"
    
    # Parar servidor atual se estiver rodando
    pkill -f "npm run dev" 2>/dev/null
    
    # Aguardar um momento
    sleep 2
    
    # Iniciar servidor
    cd citrineos-operator-ui && npm run dev &
    
    echo -e "${GREEN}🎉 Configuração concluída!${NC}"
    echo -e "${BLUE}📋 Próximos passos:${NC}"
    echo -e "1. Aguarde o servidor reiniciar (alguns segundos)"
    echo -e "2. Acesse: http://localhost:5177/"
    echo -e "3. Faça login e teste os mapas"
    echo ""
    echo -e "${YELLOW}💡 Se os mapas não funcionarem:${NC}"
    echo -e "   • Verifique se a API key está correta"
    echo -e "   • Confirme se as APIs estão habilitadas no Google Cloud"
    echo -e "   • Verifique as restrições da API key"
else
    echo -e "${RED}❌ Erro ao configurar a API key${NC}"
    exit 1
fi
