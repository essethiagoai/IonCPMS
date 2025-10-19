#!/bin/bash

echo "🔋 Testando Conexão EVerest ↔ CitrineOS"
echo "======================================="
echo ""

# Verificar se o CitrineOS está rodando
echo "🔍 Verificando CitrineOS..."
if curl -s http://localhost:8080/docs > /dev/null; then
    echo "✅ CitrineOS está rodando em http://localhost:8080"
else
    echo "❌ CitrineOS não está rodando"
    exit 1
fi

# Verificar se o EVerest está rodando
echo ""
echo "🔍 Verificando EVerest..."
if curl -s http://localhost:1880/ui/ > /dev/null; then
    echo "✅ EVerest UI está rodando em http://localhost:1880/ui/"
else
    echo "❌ EVerest não está rodando"
    exit 1
fi

# Verificar containers do EVerest
echo ""
echo "🔍 Verificando containers do EVerest..."
docker ps --filter "name=everest-ac-demo" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Verificar carregador no CitrineOS
echo ""
echo "🔍 Verificando carregador no CitrineOS..."
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { ChargingStations(where: {id: {_eq: \"cp001\"}}) { id locationId chargePointVendor chargePointModel protocol isOnline } }"
  }' | jq '.data.ChargingStations[]' 2>/dev/null || echo "Erro ao consultar carregador"

# Verificar logs do EVerest
echo ""
echo "🔍 Verificando logs do EVerest (últimas 10 linhas)..."
docker logs everest-ac-demo-manager-1 --tail 10 2>/dev/null || echo "Nenhum log disponível"

# Verificar logs do CitrineOS para conexões OCPP
echo ""
echo "🔍 Verificando logs do CitrineOS para conexões OCPP..."
docker logs server-citrine-1 --tail 20 2>/dev/null | grep -i "ocpp\|cp001\|everest" || echo "Nenhuma conexão OCPP encontrada nos logs"

echo ""
echo "🎯 Próximos Passos:"
echo ""
echo "1. 🌐 Acesse a interface do EVerest:"
echo "   http://localhost:1880/ui/"
echo ""
echo "2. 🎮 Simule eventos de carregamento:"
echo "   - Plug/Unplug do veículo"
echo "   - Start/Stop de transações"
echo "   - Pause/Resume de carregamento"
echo ""
echo "3. 📊 Monitore no Operator UI:"
echo "   http://localhost:5176/ → Transactions"
echo ""
echo "4. 📝 Verifique logs em tempo real:"
echo "   docker logs -f everest-ac-demo-manager-1"
echo "   docker logs -f server-citrine-1"
echo ""
echo "5. 🔗 URLs úteis:"
echo "   - EVerest UI: http://localhost:1880/ui/"
echo "   - NodeRed: http://localhost:1880/"
echo "   - Operator UI: http://localhost:5176/"
echo "   - API Docs: http://localhost:8080/docs"
echo ""
echo "💡 Se não houver conexão automática, aguarde alguns minutos"
echo "   para o EVerest estabelecer a conexão OCPP com o CitrineOS."
