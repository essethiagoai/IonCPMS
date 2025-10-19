#!/bin/bash

echo "🧪 Testando correção do erro GraphQL 404..."
echo ""

# Verificar se o servidor está rodando
echo "🔍 Verificando se o servidor está rodando..."
if curl -s http://localhost:5176/ > /dev/null; then
    echo "✅ Servidor Operator UI está rodando em http://localhost:5176/"
else
    echo "❌ Servidor Operator UI não está rodando"
    echo "💡 Execute: cd citrineos-operator-ui && npm run dev"
    exit 1
fi

echo ""
echo "🔍 Verificando se o GraphQL está acessível..."
if curl -s http://localhost:8090/v1/graphql -X POST -H "Content-Type: application/json" -d '{"query":"query { __schema { types { name } } }"}' | grep -q "data"; then
    echo "✅ GraphQL está funcionando em http://localhost:8090/v1/graphql"
else
    echo "❌ GraphQL não está acessível"
    echo "💡 Verifique se o CitrineOS está rodando: ./check-services.sh"
    exit 1
fi

echo ""
echo "🎯 Teste da Correção do Erro GraphQL:"
echo ""
echo "1. Acesse: http://localhost:5176/"
echo "2. Faça login com:"
echo "   - Email: admin@citrineos.com"
echo "   - Senha: CitrineOS!"
echo ""
echo "3. Abra o DevTools (F12) e vá para a aba Console"
echo ""
echo "4. Navegue pela aplicação e verifique se:"
echo ""
echo "   ✅ NÃO aparece mais: 'GraphQL Error (Code: 404): Route POST:/ not found'"
echo "   ✅ NÃO aparece mais: 'Error (status code: undefined)'"
echo "   ✅ As requisições GraphQL funcionam corretamente"
echo ""
echo "5. Teste específico - Vá para: Transactions"
echo ""
echo "6. Verifique se:"
echo "   - ✅ A página carrega sem erros"
echo "   - ✅ A lista de transações é exibida (mesmo que vazia)"
echo "   - ✅ NÃO há erros GraphQL no console"
echo ""
echo "7. Teste outras páginas:"
echo "   - Locations → Lista"
echo "   - Locations → Map"
echo "   - Charging Stations"
echo ""
echo "🔧 Correções Aplicadas:"
echo "   - Corrigido URL da API GraphQL: 8080 → 8090"
echo "   - Adicionado prefixo VITE_ para variáveis de ambiente"
echo "   - Mantido compatibilidade com REACT_APP_"
echo "   - Atualizado config.js com URLs corretas"
echo ""
echo "📍 Configurações Corrigidas:"
echo "   - VITE_API_URL: http://localhost:8090/v1/graphql"
echo "   - VITE_WS_URL: ws://localhost:8090/v1/graphql"
echo "   - GraphQL Engine: porta 8090 (não 8080)"
echo ""
echo "🎉 Se não houver mais erros GraphQL, a correção funcionou!"
echo ""
echo "💡 Esta correção resolve:"
echo "   - Erro 404 do GraphQL"
echo "   - Configuração incorreta de portas"
echo "   - Variáveis de ambiente com prefixo errado"
echo "   - Conectividade com o backend CitrineOS"
