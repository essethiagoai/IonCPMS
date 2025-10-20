#!/bin/bash

echo "🚗 Teste Interativo - Íon CPMS com EVerest"
echo "=========================================="
echo ""

# Função para verificar se um serviço está rodando
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=$3
    
    echo -n "🔍 Verificando $service_name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_status"; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FALHOU"
        return 1
    fi
}

# Função para aguardar entrada do usuário
wait_for_user() {
    echo ""
    echo "⏸️  Pressione ENTER para continuar..."
    read -r
}

# Função para abrir URL no navegador
open_url() {
    local url=$1
    local description=$2
    
    echo "🌐 Abrindo $description..."
    echo "   URL: $url"
    
    if command -v open >/dev/null 2>&1; then
        open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
    else
        echo "   Por favor, abra manualmente: $url"
    fi
}

echo "📋 PASSO 1: Verificação de Serviços"
echo "===================================="

# Verificar CitrineOS
echo "🔍 Verificando CitrineOS..."
if ./check-services.sh >/dev/null 2>&1; then
    echo "✅ CitrineOS está rodando"
else
    echo "❌ CitrineOS não está rodando"
    echo "   Execute: ./setup-citrineos.sh"
    exit 1
fi

# Verificar EVerest
echo "🔍 Verificando EVerest..."
if docker ps | grep -q everest; then
    echo "✅ EVerest está rodando"
else
    echo "❌ EVerest não está rodando"
    echo "   Execute: ./setup-everest-citrineos.sh"
    exit 1
fi

wait_for_user

echo ""
echo "📋 PASSO 2: Acesso às Interfaces"
echo "================================"

echo "🌐 Abrindo interfaces no navegador..."

# Abrir Operator UI
open_url "http://localhost:5176" "Operator UI (Frontend)"

wait_for_user

# Abrir EVerest UI
open_url "http://localhost:1880" "EVerest UI (Simulador)"

wait_for_user

# Abrir API Documentation
open_url "http://localhost:8080/docs" "API Documentation"

wait_for_user

echo ""
echo "📋 PASSO 3: Configuração do Carregador"
echo "======================================"

echo "🎯 Agora você precisa:"
echo "1. Fazer login no Operator UI (admin@citrineos.com / CitrineOS!)"
echo "2. Ir para Locations → Create Location"
echo "3. Criar uma localização de teste"
echo "4. Adicionar uma estação de carregamento com ID: cp001"

wait_for_user

echo ""
echo "📋 PASSO 4: Conectar EVerest"
echo "============================"

echo "🔧 Configurando conexão EVerest → CitrineOS..."
if ./setup-everest-citrineos.sh; then
    echo "✅ EVerest configurado com sucesso"
else
    echo "❌ Erro na configuração do EVerest"
    exit 1
fi

wait_for_user

echo ""
echo "📋 PASSO 5: Verificar Conexão"
echo "============================="

echo "🔍 Verificando conexão EVerest → CitrineOS..."
if ./test-everest-final.sh; then
    echo "✅ Conexão estabelecida com sucesso"
else
    echo "❌ Problema na conexão"
    echo "   Verifique os logs: docker logs everest-ac-demo-manager-1"
fi

wait_for_user

echo ""
echo "📋 PASSO 6: Teste de Transação"
echo "============================="

echo "🎮 Agora você pode testar:"
echo ""
echo "1. No EVerest UI (Node-RED):"
echo "   - Procure pelo nó 'Start Transaction'"
echo "   - Clique para iniciar uma transação"
echo "   - Use ID Tag: DEADBEEFDEADBEEF"
echo ""
echo "2. No Operator UI:"
echo "   - Vá para Charging Stations"
echo "   - Verifique se cp001 está online"
echo "   - Vá para Transactions para ver transações ativas"

wait_for_user

echo ""
echo "📋 PASSO 7: Monitoramento"
echo "========================"

echo "📊 Para monitorar o sistema:"
echo ""
echo "1. Logs do CitrineOS:"
echo "   docker compose logs -f"
echo ""
echo "2. Logs do EVerest:"
echo "   docker logs -f everest-ac-demo-manager-1"
echo ""
echo "3. Status do carregador:"
echo "   docker exec everest-ac-demo-manager-1 tail -f /ext/dist/log/everest.log"

wait_for_user

echo ""
echo "📋 PASSO 8: Testes Avançados"
echo "==========================="

echo "🧪 Testes que você pode realizar:"
echo ""
echo "1. ✅ Carregamento normal (início → fim)"
echo "2. ❌ Falha de autorização (ID Tag inválido)"
echo "3. ⏹️  Interrupção manual de carregamento"
echo "4. 🔄 Múltiplas transações simultâneas"
echo "5. 📊 Verificar dados no banco de dados"

wait_for_user

echo ""
echo "📋 PASSO 9: Verificação Final"
echo "============================"

echo "🔍 Checklist de funcionamento:"
echo ""
echo "□ Carregador aparece como online no Operator UI"
echo "□ Transações são iniciadas com sucesso"
echo "□ Dados são salvos no banco de dados"
echo "□ Interface atualiza em tempo real"
echo "□ Logs mostram comunicação OCPP funcionando"

wait_for_user

echo ""
echo "🎉 TESTE CONCLUÍDO!"
echo "==================="
echo ""
echo "✅ Seu sistema Íon CPMS está funcionando com EVerest!"
echo ""
echo "📚 Para mais informações, consulte:"
echo "   - GUIA_TESTE_EVEREST.md (guia completo)"
echo "   - README.md (documentação geral)"
echo "   - PROJECT_SUMMARY.md (resumo do projeto)"
echo ""
echo "🚀 Próximos passos:"
echo "   1. Testar cenários mais complexos"
echo "   2. Configurar múltiplos carregadores"
echo "   3. Implementar funcionalidades adicionais"
echo "   4. Preparar para deploy em produção"
echo ""
echo "Obrigado por testar o Íon CPMS! 🚗⚡"
