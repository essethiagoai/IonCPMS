#!/bin/bash

echo "🔍 Verificação Rápida - Teste EVerest"
echo "====================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar status
check_status() {
    local service=$1
    local command=$2
    local expected=$3
    
    echo -n "🔍 $service... "
    
    if eval "$command" | grep -q "$expected"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FALHOU${NC}"
        return 1
    fi
}

# Função para verificar URL
check_url() {
    local name=$1
    local url=$2
    
    echo -n "🌐 $name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FALHOU${NC}"
        return 1
    fi
}

echo -e "${BLUE}📊 Status dos Serviços:${NC}"
echo "========================"

# Verificar CitrineOS
check_status "CitrineOS Backend" "docker ps" "server-citrine-1"
check_status "PostgreSQL" "docker ps" "server-ocpp-db-1"
check_status "GraphQL Engine" "docker ps" "server-graphql-engine-1"

echo ""

# Verificar EVerest
check_status "EVerest Manager" "docker ps" "everest-ac-demo-manager-1"
check_status "EVerest Node-RED" "docker ps" "everest-ac-demo-nodered-1"
check_status "EVerest MQTT" "docker ps" "everest-ac-demo-mqtt-server-1"

echo ""

echo -e "${BLUE}🌐 Conectividade:${NC}"
echo "=================="

# Verificar URLs
check_url "Operator UI" "http://localhost:5176"
check_url "EVerest UI" "http://localhost:1880"
check_url "API Docs" "http://localhost:8080/docs"
check_url "GraphQL API" "http://localhost:8090/v1/graphql"

echo ""

echo -e "${BLUE}🔌 Conexão OCPP:${NC}"
echo "=================="

# Verificar se o carregador está registrado
echo -n "🔍 Carregador cp001 registrado... "
if curl -s "http://localhost:8090/v1/graphql" \
    -H "Content-Type: application/json" \
    -d '{"query":"query { ChargingStations(where: {id: {_eq: \"cp001\"}}) { id isOnline } }"}' \
    | grep -q "cp001"; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${YELLOW}⚠️  NÃO ENCONTRADO${NC}"
    echo "   Execute: ./setup-everest-citrineos.sh"
fi

echo ""

echo -e "${BLUE}📋 Próximos Passos:${NC}"
echo "====================="

echo "1. 🌐 Acesse as interfaces:"
echo "   • Operator UI: http://localhost:5176"
echo "   • EVerest UI: http://localhost:1880"
echo "   • API Docs: http://localhost:8080/docs"

echo ""
echo "2. 🎮 Teste transações:"
echo "   • No EVerest UI, clique em 'Start Transaction'"
echo "   • Use ID Tag: DEADBEEFDEADBEEF"
echo "   • Monitore no Operator UI"

echo ""
echo "3. 📊 Monitore logs:"
echo "   • CitrineOS: docker compose logs -f"
echo "   • EVerest: docker logs -f everest-ac-demo-manager-1"

echo ""
echo "4. 🧪 Execute teste completo:"
echo "   ./teste-interativo-everest.sh"

echo ""
echo -e "${GREEN}🎉 Sistema pronto para testes!${NC}"
