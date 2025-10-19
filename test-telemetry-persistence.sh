#!/bin/bash

echo "🧪 Testando persistência da escolha de métricas anônimas..."
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
echo "🎯 Teste de Persistência de Métricas:"
echo ""
echo "1. Acesse: http://localhost:5176/"
echo ""
echo "2. Se aparecer o modal 'Anonymous Metrics Consent':"
echo "   - Escolha 'Accept' ou 'Reject'"
echo "   - Clique no botão escolhido"
echo ""
echo "3. Atualize a página (F5 ou Ctrl+R)"
echo ""
echo "4. Verifique se:"
echo "   ✅ O modal NÃO aparece novamente"
echo "   ✅ A escolha foi persistida"
echo ""
echo "5. Para testar a limpeza:"
echo "   - Abra o DevTools (F12)"
echo "   - Vá para Application → Local Storage"
echo "   - Procure por 'citrineos-telemetry-consent'"
echo "   - Delete a chave se quiser testar novamente"
echo ""
echo "🔧 Correção aplicada:"
echo "   - Adicionado localStorage para persistir a escolha"
echo "   - Fallback para API do backend (quando disponível)"
echo "   - Escolha é salva localmente no navegador"
echo ""
echo "📍 Como funciona:"
echo "   - Primeira vez: Modal aparece"
echo "   - Usuário escolhe: Escolha é salva no localStorage"
echo "   - Próximas vezes: Escolha é lida do localStorage"
echo "   - Modal não aparece mais"
echo ""
echo "🎉 Se o modal não aparecer após atualizar, a correção funcionou!"
