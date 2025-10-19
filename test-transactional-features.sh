#!/bin/bash

echo "🔋 Testador de Funcionalidades Transacionais - CitrineOS"
echo "========================================================"
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
echo "🎯 Escolha uma opção para testar transações:"
echo ""
echo "1. 🚀 EVerest Simulator (Recomendado)"
echo "   - Simulador completo de carregador OCPP 2.0.1"
echo "   - Interface web para controle"
echo "   - Simula eventos reais de carregamento"
echo ""
echo "2. 🛠️ Simulador OCPP Simples"
echo "   - Simulador básico em Node.js"
echo "   - Conecta via WebSocket"
echo "   - Simula transações básicas"
echo ""
echo "3. 🎯 Testes via API REST"
echo "   - Testes diretos via GraphQL"
echo "   - Criação e manipulação de transações"
echo "   - Verificação de dados"
echo ""
echo "4. 🎮 Interface Web Interativa"
echo "   - Interface HTML para testes"
echo "   - Controles visuais"
echo "   - Logs em tempo real"
echo ""
echo "5. 📊 Verificar Transações Existentes"
echo "   - Listar transações no banco"
echo "   - Verificar status"
echo ""

read -p "Digite sua escolha (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Configurando EVerest Simulator..."
        ./setup-everest-simulator.sh
        ;;
    2)
        echo ""
        echo "🛠️ Criando Simulador OCPP Simples..."
        ./create-ocpp-simulator.sh
        ;;
    3)
        echo ""
        echo "🎯 Executando Testes via API..."
        ./test-transactions-api.sh
        ;;
    4)
        echo ""
        echo "🎮 Abrindo Interface Web Interativa..."
        echo "📂 Arquivo criado: create-transaction-tester.html"
        echo "🌐 Abra o arquivo no seu navegador para usar a interface"
        echo "💡 Certifique-se de que o CitrineOS está rodando em http://localhost:8080"
        ;;
    5)
        echo ""
        echo "📊 Verificando Transações Existentes..."
        curl -s -X POST http://localhost:8090/v1/graphql \
          -H "Content-Type: application/json" \
          -d '{
            "query": "query { Transactions(limit: 10, order_by: {createdAt: desc}) { id transactionId stationId isActive chargingState totalKwh timeSpentCharging createdAt updatedAt } }"
          }' | jq '.data.Transactions[]' 2>/dev/null || echo "Nenhuma transação encontrada"
        ;;
    *)
        echo "❌ Opção inválida"
        exit 1
        ;;
esac

echo ""
echo "🎉 Teste de funcionalidades transacionais concluído!"
echo ""
echo "💡 Dicas para testes eficazes:"
echo "   - Use o EVerest para simular carregadores reais"
echo "   - Monitore logs no console do CitrineOS"
echo "   - Verifique dados no Operator UI"
echo "   - Teste diferentes cenários de carregamento"
echo ""
echo "🔗 Links úteis:"
echo "   - Operator UI: http://localhost:5176/"
echo "   - API Docs: http://localhost:8080/docs"
echo "   - GraphQL Playground: http://localhost:8090/v1/graphql"
