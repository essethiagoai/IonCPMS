#!/bin/bash

echo "🔋 Configurando EVerest para conectar ao CitrineOS"
echo "=================================================="
echo ""

# Verificar se o CitrineOS está rodando
echo "🔍 Verificando se o CitrineOS está rodando..."
if curl -s http://localhost:8080/docs > /dev/null; then
    echo "✅ CitrineOS está rodando em http://localhost:8080"
else
    echo "❌ CitrineOS não está rodando"
    echo "💡 Execute: cd citrineos-core && docker compose up -d"
    exit 1
fi

# Verificar se o carregador cp001 existe
echo ""
echo "🔍 Verificando se o carregador cp001 existe..."
CHARGER_EXISTS=$(curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { ChargingStations(where: {id: {_eq: \"cp001\"}}) { id } }"}' | \
  jq -r '.data.ChargingStations | length')

if [ "$CHARGER_EXISTS" -gt 0 ]; then
    echo "✅ Carregador cp001 encontrado"
else
    echo "❌ Carregador cp001 não encontrado"
    echo "💡 Execute: ./citrineos/add-charger-and-rfid-card.sh"
    exit 1
fi

# Parar containers existentes do EVerest
echo ""
echo "🛑 Parando containers existentes do EVerest..."
docker compose --project-name everest-ac-demo --file "docker-compose.ocpp201.yml" down 2>/dev/null || true

# Iniciar containers do EVerest
echo ""
echo "🚀 Iniciando containers do EVerest..."
docker compose --project-name everest-ac-demo --file "docker-compose.ocpp201.yml" up -d

# Aguardar containers iniciarem
echo ""
echo "⏳ Aguardando containers iniciarem..."
sleep 10

# Copiar configuração personalizada
echo ""
echo "📋 Copiando configuração personalizada..."
docker cp config-citrineos-ocpp201.yaml everest-ac-demo-manager-1:/ext/dist/etc/everest/config-citrineos-ocpp201.yaml

# Configurar senha do carregador no CitrineOS
echo ""
echo "🔐 Configurando senha do carregador no CitrineOS..."
curl -s -X PUT "http://localhost:8080/data/monitoring/variableAttribute?stationId=cp001&setOnCharger=true" \
  --header "Content-Type: application/json" \
  --data-raw '{
    "component": {
      "name": "SecurityCtrlr"
    },
    "variable": {
      "name": "BasicAuthPassword"
    },
    "variableAttribute": [
      {
        "value": "DEADBEEFDEADBEEF"
      }
    ],
    "variableCharacteristics": {
      "dataType": "passwordString",
      "supportsMonitoring": false
    }
  }' > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Senha configurada com sucesso"
else
    echo "⚠️  Falha ao configurar senha (pode ser normal se já estiver configurada)"
fi

# Configurar autorização RFID
echo ""
echo "🎫 Configurando autorização RFID..."
curl -s -X PUT "http://localhost:8080/data/evdriver/authorization?idToken=DEADBEEF&type=ISO14443" \
  --header "Content-Type: application/json" \
  --data-raw '{
    "idToken": {
      "idToken": "DEADBEEF",
      "type": "ISO14443"
    },
    "idTokenInfo": {
      "status": "Accepted"
    }
  }' > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Autorização RFID configurada com sucesso"
else
    echo "⚠️  Falha ao configurar autorização RFID (pode ser normal se já estiver configurada)"
fi

# Iniciar EVerest com configuração personalizada
echo ""
echo "🚀 Iniciando EVerest com configuração personalizada..."
docker exec everest-ac-demo-manager-1 sh -c "
  export EVEREST_CONFIG=/ext/dist/etc/everest/config-citrineos-ocpp201.yaml
  /ext/build/run-scripts/run-sil-ocpp201.sh
" &

# Aguardar um pouco para o EVerest iniciar
echo ""
echo "⏳ Aguardando EVerest iniciar..."
sleep 15

# Verificar se o EVerest está rodando
echo ""
echo "🔍 Verificando se o EVerest está rodando..."
EVEREST_RUNNING=$(docker exec everest-ac-demo-manager-1 ps aux | grep -c "ocpp:OCPP201" || echo "0")

if [ "$EVEREST_RUNNING" -gt 0 ]; then
    echo "✅ EVerest está rodando com OCPP 2.0.1"
else
    echo "❌ EVerest não está rodando corretamente"
    echo "💡 Verifique os logs: docker logs everest-ac-demo-manager-1"
fi

echo ""
echo "🎯 Próximos Passos:"
echo ""
echo "1. 🌐 Acesse a interface do EVerest:"
echo "   http://localhost:1880/ui/"
echo ""
echo "2. 🎮 Teste as funcionalidades:"
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
echo "💡 Se houver problemas, verifique:"
echo "   - Se o CitrineOS está rodando"
echo "   - Se o carregador cp001 existe"
echo "   - Se a senha foi configurada corretamente"
echo ""
echo "🎉 Setup concluído! Agora você pode testar as funcionalidades transacionais."
