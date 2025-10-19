#!/bin/bash

echo "🧪 Testando correção do erro de atualização de localização..."
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
echo "🎯 Teste de Atualização de Localização:"
echo ""
echo "1. Acesse: http://localhost:5176/"
echo "2. Faça login com:"
echo "   - Email: admin@citrineos.com"
echo "   - Senha: CitrineOS!"
echo ""
echo "3. Vá para: Locations → Editar uma localização existente"
echo ""
echo "4. Teste os campos de coordenadas:"
echo "   - Altere a latitude para: -23.5505"
echo "   - Altere a longitude para: -46.6333"
echo "   - Clique em Submit"
echo ""
echo "5. Verifique se:"
echo "   ✅ Não aparece erro 'field latitude not found'"
echo "   ✅ A localização é atualizada com sucesso"
echo "   ✅ Os campos de latitude e longitude funcionam independentemente"
echo ""
echo "🔧 Correção aplicada:"
echo "   - Removido 'name' dos campos latitude e longitude"
echo "   - Mantido apenas o campo 'coordinates' no GraphQL"
echo "   - Campos ainda funcionam para entrada manual"
echo ""
echo "📍 Coordenadas de teste:"
echo "   - São Paulo: Lat: -23.5505, Lng: -46.6333"
echo "   - Rio de Janeiro: Lat: -22.9068, Lng: -43.1729"
echo "   - Brasília: Lat: -15.7801, Lng: -47.9292"
echo ""
echo "🎉 Se não houver erros, a correção funcionou!"
