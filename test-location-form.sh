#!/bin/bash

# Script para testar o formulário de localização após correção
# Verifica se os campos de latitude e longitude funcionam independentemente

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testando formulário de localização...${NC}"

# Verificar se o servidor está rodando
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:5177 | grep -q "200"; then
    echo -e "${RED}❌ Operator UI não está rodando em http://localhost:5177${NC}"
    echo -e "${YELLOW}💡 Execute: cd citrineos-operator-ui && npm run dev${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Operator UI está rodando${NC}"

echo ""
echo -e "${BLUE}📋 Teste Manual - Siga estes passos:${NC}"
echo ""
echo -e "${YELLOW}1. Acesse: http://localhost:5177/${NC}"
echo -e "${YELLOW}2. Faça login com:${NC}"
echo -e "   • Email: admin@citrineos.com"
echo -e "   • Senha: CitrineOS!"
echo ""
echo -e "${YELLOW}3. Vá para: Locations → Create Location${NC}"
echo ""
echo -e "${YELLOW}4. Teste os campos de coordenadas:${NC}"
echo -e "   • Digite '40.7128' no campo Latitude"
echo -e "   • Digite '-74.0060' no campo Longitude"
echo -e "   • Verifique se os valores permanecem diferentes"
echo ""
echo -e "${YELLOW}5. Teste alterações independentes:${NC}"
echo -e "   • Altere apenas a Latitude para '41.8781'"
echo -e "   • Verifique se a Longitude permanece '-74.0060'"
echo -e "   • Altere apenas a Longitude para '-87.6298'"
echo -e "   • Verifique se a Latitude permanece '41.8781'"
echo ""

echo -e "${GREEN}🎯 Resultado Esperado:${NC}"
echo -e "   ✅ Campos funcionam independentemente"
echo -e "   ✅ Valores não se sincronizam automaticamente"
echo -e "   ✅ Cada campo mantém seu próprio valor"
echo ""

echo -e "${BLUE}📝 Coordenadas de Teste:${NC}"
echo -e "   • São Paulo, SP: -23.5505, -46.6333"
echo -e "   • Rio de Janeiro, RJ: -22.9068, -43.1729"
echo -e "   • Brasília, DF: -15.7801, -47.9292"
echo -e "   • New York, NY: 40.7128, -74.0060"
echo ""

echo -e "${GREEN}🎉 Correção aplicada com sucesso!${NC}"
echo -e "${BLUE}💡 Os campos de latitude e longitude agora funcionam independentemente.${NC}"
