# 🔋 Guia Completo do EVerest Simulator

## ✅ Setup Concluído com Sucesso!

O EVerest Simulator foi configurado e está rodando. Agora você pode testar todas as funcionalidades transacionais do CitrineOS sem precisar de um carregador físico.

## 🚀 Status Atual

- ✅ **CitrineOS**: Rodando em `http://localhost:8080`
- ✅ **EVerest**: Rodando em `http://localhost:1880/ui/`
- ✅ **Carregador**: `cp001` criado no CitrineOS
- ✅ **Containers**: Todos os containers do EVerest estão ativos

## 🎮 Como Usar o EVerest

### 1. 🌐 Acesse a Interface Web
```
http://localhost:1880/ui/
```

### 2. 🎯 Controles Disponíveis

#### **Plug/Unplug do Veículo**
- **Plug**: Simula conectar o cabo de carregamento
- **Unplug**: Simula desconectar o cabo

#### **Start/Stop de Transações**
- **Start**: Inicia uma transação de carregamento
- **Stop**: Para a transação atual

#### **Pause/Resume**
- **Pause**: Pausa o carregamento
- **Resume**: Retoma o carregamento

#### **Status do Carregador**
- **Available**: Carregador disponível
- **Occupied**: Carregador ocupado
- **Charging**: Carregando
- **Faulted**: Com erro

### 3. 📊 Monitoramento

#### **No Operator UI**
```
http://localhost:5176/ → Transactions
```

#### **Logs em Tempo Real**
```bash
# Logs do EVerest
docker logs -f everest-ac-demo-manager-1

# Logs do CitrineOS
docker logs -f server-citrine-1
```

## 🧪 Cenários de Teste

### **Cenário 1: Carregamento Completo**
1. Acesse `http://localhost:1880/ui/`
2. Clique em **"Plug"** para conectar o veículo
3. Clique em **"Start"** para iniciar o carregamento
4. Monitore no Operator UI: `http://localhost:5176/`
5. Clique em **"Stop"** para parar
6. Clique em **"Unplug"** para desconectar

### **Cenário 2: Carregamento com Pausa**
1. Conecte o veículo (**Plug**)
2. Inicie o carregamento (**Start**)
3. Pause o carregamento (**Pause**)
4. Retome o carregamento (**Resume**)
5. Pare o carregamento (**Stop**)
6. Desconecte o veículo (**Unplug**)

### **Cenário 3: Teste de Erro**
1. Conecte o veículo
2. Inicie o carregamento
3. Simule um erro no carregador
4. Verifique como o sistema lida com o erro
5. Corrija o erro e retome o carregamento

## 📈 Métricas e Dados

### **Dados de Transação**
- **Energia Total**: kWh consumidos
- **Tempo de Carregamento**: Duração da sessão
- **Status**: Ativa/Finalizada
- **Estado**: Charging/Completed/Stopped

### **Dados do Carregador**
- **Status**: Online/Offline
- **Conectores**: Disponíveis/Ocupados
- **Potência**: Máxima/Atual
- **Temperatura**: Monitoramento térmico

## 🔧 Configurações Avançadas

### **Modificar Parâmetros**
- Acesse `http://localhost:1880/` (NodeRed)
- Edite os fluxos para modificar comportamentos
- Reinicie os containers após mudanças

### **Logs OCPP**
- Acesse `http://localhost:8888/` (se disponível)
- Visualize mensagens OCPP em tempo real
- Analise protocolo de comunicação

## 🚨 Solução de Problemas

### **EVerest não conecta ao CitrineOS**
```bash
# Verificar se ambos estão rodando
./test-everest-connection.sh

# Reiniciar EVerest
cd everest-demo
docker compose --project-name everest-ac-demo --file "docker-compose.ocpp201.yml" restart
```

### **Interface não carrega**
```bash
# Verificar containers
docker ps --filter "name=everest-ac-demo"

# Verificar logs
docker logs everest-ac-demo-nodered-1
```

### **Transações não aparecem**
```bash
# Verificar carregador no CitrineOS
curl -s -X POST http://localhost:8090/v1/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { ChargingStations { id isOnline } }"}'
```

## 🎯 Funcionalidades Testáveis

- ✅ **Início de Transações**
- ✅ **Parada de Transações**
- ✅ **Pausa/Retomada**
- ✅ **Monitoramento em Tempo Real**
- ✅ **Relatórios de Energia**
- ✅ **Status do Carregador**
- ✅ **Autorizações**
- ✅ **Tarifação**
- ✅ **Métricas e Analytics**
- ✅ **Tratamento de Erros**

## 🔗 Links Úteis

- **EVerest UI**: http://localhost:1880/ui/
- **NodeRed**: http://localhost:1880/
- **Operator UI**: http://localhost:5176/
- **API Docs**: http://localhost:8080/docs
- **GraphQL**: http://localhost:8090/v1/graphql

## 🎉 Pronto para Testar!

Agora você tem um ambiente completo para testar todas as funcionalidades transacionais do CitrineOS. O EVerest simula um carregador real com OCPP 2.0.1, permitindo testar todos os cenários possíveis de carregamento de veículos elétricos.

**Divirta-se testando! 🚗⚡**
