#!/bin/bash

echo "🎯 Testando Transações via API REST..."
echo ""

# Verificar se o CitrineOS está rodando
echo "🔍 Verificando se o CitrineOS está rodando..."
if curl -s http://localhost:8080/docs > /dev/null; then
    echo "✅ CitrineOS está rodando em http://localhost:8080"
else
    echo "❌ CitrineOS não está rodando"
    echo "💡 Execute: ./setup-citrineos.sh primeiro"
    exit 1
fi

echo ""
echo "📋 Testes de Transações via API:"
echo ""

# 1. Listar transações existentes
echo "1. 📊 Listando transações existentes..."
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { Transactions(limit: 5) { id transactionId isActive chargingState totalKwh timeSpentCharging createdAt } }"
  }' | jq '.data.Transactions[]' 2>/dev/null || echo "Nenhuma transação encontrada"

echo ""

# 2. Criar uma transação de teste
echo "2. ➕ Criando transação de teste..."
TRANSACTION_RESPONSE=$(curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { insert_Transactions_one(object: { stationId: \"TEST_STATION_001\", transactionId: \"TEST_TXN_'$(date +%s)'\", isActive: true, chargingState: \"Charging\", totalKwh: 0.0, timeSpentCharging: 0 }) { id transactionId isActive chargingState } }"
  }')

echo "$TRANSACTION_RESPONSE" | jq '.data.insert_Transactions_one' 2>/dev/null || echo "Erro ao criar transação"

echo ""

# 3. Atualizar transação (simular carregamento)
echo "3. 🔄 Atualizando transação (simulando carregamento)..."
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { update_Transactions(where: {isActive: {_eq: true}}, _set: { totalKwh: 15.5, timeSpentCharging: 1800, chargingState: \"Charging\" }) { affected_rows } }"
  }' | jq '.data.update_Transactions' 2>/dev/null || echo "Erro ao atualizar transação"

echo ""

# 4. Finalizar transação
echo "4. ⏹️ Finalizando transação..."
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { update_Transactions(where: {isActive: {_eq: true}}, _set: { isActive: false, chargingState: \"Completed\", totalKwh: 25.0, timeSpentCharging: 3600 }) { affected_rows } }"
  }' | jq '.data.update_Transactions' 2>/dev/null || echo "Erro ao finalizar transação"

echo ""

# 5. Verificar transações finais
echo "5. 📊 Verificando transações após testes..."
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { Transactions(limit: 5, order_by: {createdAt: desc}) { id transactionId isActive chargingState totalKwh timeSpentCharging createdAt updatedAt } }"
  }' | jq '.data.Transactions[]' 2>/dev/null || echo "Erro ao listar transações"

echo ""
echo "🎉 Testes de transações via API concluídos!"
echo ""
echo "💡 Você pode usar essas queries GraphQL para:"
echo "   - Criar transações de teste"
echo "   - Simular diferentes estados de carregamento"
echo "   - Testar relatórios e métricas"
echo "   - Verificar dados no Operator UI"
echo ""
echo "🔗 Acesse o Operator UI para ver os resultados:"
echo "   http://localhost:5176/ → Transactions"
