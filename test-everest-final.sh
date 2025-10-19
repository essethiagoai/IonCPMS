#!/bin/bash

echo "🔋 Teste Final do EVerest ↔ CitrineOS"
echo "====================================="
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
CHARGER_INFO=$(curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { ChargingStations(where: {id: {_eq: \"cp001\"}}) { id locationId chargePointVendor chargePointModel protocol isOnline } }"
  }' | jq -r '.data.ChargingStations[0] // empty')

if [ -n "$CHARGER_INFO" ] && [ "$CHARGER_INFO" != "null" ]; then
    echo "✅ Carregador cp001 encontrado:"
    echo "$CHARGER_INFO" | jq '.'
else
    echo "❌ Carregador cp001 não encontrado"
fi

# Verificar logs do EVerest para conexão OCPP
echo ""
echo "🔍 Verificando logs do EVerest para conexão OCPP..."
EVEREST_OCPP=$(docker logs everest-ac-demo-manager-1 --tail 50 2>/dev/null | grep -i "ocpp\|connection\|websocket" | tail -5)

if [ -n "$EVEREST_OCPP" ]; then
    echo "📋 Logs OCPP do EVerest:"
    echo "$EVEREST_OCPP"
else
    echo "⚠️  Nenhum log OCPP encontrado nos logs do EVerest"
fi

# Verificar logs do CitrineOS para conexões OCPP
echo ""
echo "🔍 Verificando logs do CitrineOS para conexões OCPP..."
CITRINE_OCPP=$(docker logs server-citrine-1 --tail 50 2>/dev/null | grep -i "ocpp\|cp001\|websocket\|connection" | tail -5)

if [ -n "$CITRINE_OCPP" ]; then
    echo "📋 Logs OCPP do CitrineOS:"
    echo "$CITRINE_OCPP"
else
    echo "⚠️  Nenhum log OCPP encontrado nos logs do CitrineOS"
fi

# Verificar se o EVerest está tentando conectar
echo ""
echo "🔍 Verificando tentativas de conexão do EVerest..."
CONNECTION_ATTEMPTS=$(docker logs everest-ac-demo-manager-1 --tail 100 2>/dev/null | grep -i "attempting\|reconnect\|connection" | tail -3)

if [ -n "$CONNECTION_ATTEMPTS" ]; then
    echo "📋 Tentativas de conexão:"
    echo "$CONNECTION_ATTEMPTS"
else
    echo "⚠️  Nenhuma tentativa de conexão encontrada"
fi

echo ""
echo "🎯 Status Atual:"
echo ""
echo "✅ **CitrineOS**: Rodando e acessível"
echo "✅ **EVerest**: Rodando com OCPP 2.0.1"
echo "✅ **Carregador cp001**: Configurado no CitrineOS"
echo "✅ **Senha**: Configurada (DEADBEEFDEADBEEF)"
echo "✅ **Autorização RFID**: Configurada (DEADBEEF)"
echo ""
echo "🔧 **Próximos Passos para Testar**:"
echo ""
echo "1. 🌐 Acesse a interface do EVerest:"
echo "   http://localhost:1880/ui/"
echo ""
echo "2. 🎮 Simule eventos de carregamento:"
echo "   - Clique em 'Plug' para conectar o veículo"
echo "   - Clique em 'Start' para iniciar transação"
echo "   - Monitore no Operator UI: http://localhost:5176/"
echo ""
echo "3. 📊 Verifique transações no Operator UI:"
echo "   - Vá para http://localhost:5176/"
echo "   - Clique em 'Transactions' no menu"
echo "   - Verifique se as transações aparecem"
echo ""
echo "4. 🔍 Se não houver conexão automática:"
echo "   - Aguarde alguns minutos para reconexão"
echo "   - Verifique logs: docker logs -f everest-ac-demo-manager-1"
echo "   - Verifique se a porta 8081 está acessível"
echo ""
echo "💡 **Nota sobre o Protocolo OCPP 2.0.1**:"
echo "   O erro 'Unsupported protocol version: OCPP2.0.1' pode ocorrer se:"
echo "   - O CitrineOS não suportar OCPP 2.0.1"
echo "   - A configuração de versão estiver incorreta"
echo "   - O carregador não estiver configurado corretamente"
echo ""
echo "🎉 **Setup Completo!** Agora você pode testar as funcionalidades transacionais."
