#!/bin/bash

# Script para verificar o status dos serviços do CitrineOS

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Verificando status dos serviços do CitrineOS...${NC}"
echo ""

# Verificar se estamos no diretório correto
if [ ! -d "citrineos-core" ]; then
    echo -e "${RED}❌ Diretório citrineos-core não encontrado. Execute o setup primeiro.${NC}"
    exit 1
fi

cd citrineos-core/Server

# Verificar status dos containers
echo -e "${BLUE}📊 Status dos containers:${NC}"
docker compose ps

echo ""

# Verificar se os serviços estão respondendo
echo -e "${BLUE}🌐 Testando conectividade dos serviços:${NC}"

# Testar HTTP Server
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/docs | grep -q "200"; then
    echo -e "${GREEN}✅ HTTP Server (8080) - OK${NC}"
else
    echo -e "${RED}❌ HTTP Server (8080) - Não está respondendo${NC}"
fi

# Testar WebSocket (não seguro)
if nc -z localhost 8081 2>/dev/null; then
    echo -e "${GREEN}✅ WebSocket Server (8081) - OK${NC}"
else
    echo -e "${RED}❌ WebSocket Server (8081) - Não está respondendo${NC}"
fi

# Testar WebSocket (seguro)
if nc -z localhost 8082 2>/dev/null; then
    echo -e "${GREEN}✅ WebSocket Server Seguro (8082) - OK${NC}"
else
    echo -e "${RED}❌ WebSocket Server Seguro (8082) - Não está respondendo${NC}"
fi

# Testar PostgreSQL
if nc -z localhost 5432 2>/dev/null; then
    echo -e "${GREEN}✅ PostgreSQL (5432) - OK${NC}"
else
    echo -e "${RED}❌ PostgreSQL (5432) - Não está respondendo${NC}"
fi

# Testar RabbitMQ
if nc -z localhost 5672 2>/dev/null; then
    echo -e "${GREEN}✅ RabbitMQ (5672) - OK${NC}"
else
    echo -e "${RED}❌ RabbitMQ (5672) - Não está respondendo${NC}"
fi

echo ""
echo -e "${BLUE}📋 URLs de acesso:${NC}"
echo -e "  • API Documentation: ${GREEN}http://localhost:8080/docs${NC}"
echo -e "  • OCPP WebSocket: ${GREEN}ws://localhost:8081${NC}"
echo -e "  • OCPP WebSocket Seguro: ${GREEN}wss://localhost:8082${NC}"

echo ""
echo -e "${YELLOW}💡 Para ver logs em tempo real: docker compose logs -f${NC}"
echo -e "${YELLOW}💡 Para parar serviços: docker compose down${NC}"
echo -e "${YELLOW}💡 Para reiniciar serviços: docker compose restart${NC}"

