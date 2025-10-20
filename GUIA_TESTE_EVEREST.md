# 🚗 Guia Completo: Testando Íon CPMS com EVerest

## 📋 Pré-requisitos

### ✅ Status dos Serviços
- **CitrineOS Backend**: ✅ Rodando (porta 8080-8082)
- **Operator UI**: ✅ Rodando (porta 5176)
- **EVerest Simulator**: ✅ Rodando (porta 1880)
- **Banco de Dados**: ✅ PostgreSQL (porta 5432)

## 🎯 Passo a Passo para Teste Completo

### **Passo 1: Verificar Status dos Serviços**

```bash
# Verificar CitrineOS
./check-services.sh

# Verificar EVerest
docker ps | grep everest
```

**Resultado esperado:**
- CitrineOS: 5 containers rodando
- EVerest: 3 containers rodando

---

### **Passo 2: Acessar as Interfaces**

#### 🌐 **Operator UI (Frontend)**
- **URL**: http://localhost:5176
- **Login**: admin@citrineos.com
- **Senha**: CitrineOS!

#### 🎮 **EVerest UI (Simulador)**
- **URL**: http://localhost:1880
- **Interface**: Node-RED para controle do carregador

#### 📚 **API Documentation**
- **URL**: http://localhost:8080/docs
- **Função**: Documentação completa da API

---

### **Passo 3: Configurar o Carregador no CitrineOS**

#### 3.1 **Acessar Operator UI**
1. Abra http://localhost:5176
2. Faça login com as credenciais
3. Vá para **Locations** → **Create Location**

#### 3.2 **Criar uma Localização**
```
Nome: Teste EVerest
Endereço: Rua Teste, 123, São Paulo, SP
País: Brazil
Estado: São Paulo
Cidade: São Paulo
CEP: 01234-567
```

#### 3.3 **Adicionar Estação de Carregamento**
1. Na localização criada, clique em **Add Charging Station**
2. Configure:
   ```
   ID: cp001
   Nome: EVerest Test Station
   Protocolo: OCPP 2.0.1
   Status: Online
   ```

---

### **Passo 4: Conectar EVerest ao CitrineOS**

#### 4.1 **Executar Script de Configuração**
```bash
./setup-everest-citrineos.sh
```

Este script irá:
- Parar containers EVerest existentes
- Iniciar com configuração personalizada
- Conectar ao CitrineOS via WebSocket
- Configurar senha do carregador

#### 4.2 **Verificar Conexão**
```bash
./test-everest-final.sh
```

---

### **Passo 5: Testar Funcionalidades**

#### 5.1 **Verificar Status do Carregador**
1. No Operator UI, vá para **Charging Stations**
2. Verifique se `cp001` aparece como **Online**
3. Clique no carregador para ver detalhes

#### 5.2 **Testar Transação de Carregamento**

##### **Via EVerest UI (Node-RED)**
1. Acesse http://localhost:1880
2. Procure pelo nó **"Start Transaction"**
3. Clique no botão para iniciar transação
4. Configure:
   ```
   Connector ID: 1
   ID Tag: DEADBEEFDEADBEEF
   ```

##### **Via Operator UI**
1. Vá para **Transactions**
2. Clique em **Start Transaction**
3. Selecione o carregador `cp001`
4. Configure os parâmetros

#### 5.3 **Monitorar Transação**
1. **Operator UI** → **Transactions**: Veja transações ativas
2. **EVerest UI**: Monitore status em tempo real
3. **Logs**: Verifique logs para debug

---

### **Passo 6: Testes Avançados**

#### 6.1 **Teste de Autorização RFID**
```bash
# Adicionar cartão RFID
curl -X POST http://localhost:8080/ocpprouter/authorization \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "DEADBEEFDEADBEEF",
    "idTokenType": "ISO14443",
    "status": "Accepted"
  }'
```

#### 6.2 **Teste de Parada de Transação**
1. No EVerest UI, clique em **"Stop Transaction"**
2. Ou via Operator UI → **Transactions** → **Stop**

#### 6.3 **Teste de Status do Conector**
1. **Operator UI** → **Charging Stations** → **cp001**
2. Verifique status dos conectores
3. Monitore mudanças em tempo real

---

### **Passo 7: Debugging e Logs**

#### 7.1 **Logs do CitrineOS**
```bash
# Logs em tempo real
docker compose logs -f

# Logs específicos
docker compose logs -f server-citrine-1
```

#### 7.2 **Logs do EVerest**
```bash
# Logs do manager
docker logs -f everest-ac-demo-manager-1

# Logs do Node-RED
docker logs -f everest-ac-demo-nodered-1
```

#### 7.3 **Verificar Conexão WebSocket**
```bash
# Testar conexão
wscat -c ws://localhost:8081/cp001
```

---

### **Passo 8: Cenários de Teste**

#### 8.1 **Cenário 1: Carregamento Normal**
1. ✅ Carregador online
2. ✅ Autorização aceita
3. ✅ Transação iniciada
4. ✅ Carregamento em andamento
5. ✅ Transação finalizada

#### 8.2 **Cenário 2: Falha de Autorização**
1. ❌ ID Tag inválido
2. ✅ Transação rejeitada
3. ✅ Status atualizado

#### 8.3 **Cenário 3: Interrupção de Carregamento**
1. ✅ Transação ativa
2. ✅ Parada manual
3. ✅ Dados salvos

---

### **Passo 9: Verificações Finais**

#### 9.1 **Checklist de Funcionalidades**
- [ ] Carregador conectado ao CitrineOS
- [ ] Status online/offline funcionando
- [ ] Autorização RFID funcionando
- [ ] Início de transação funcionando
- [ ] Parada de transação funcionando
- [ ] Dados salvos no banco
- [ ] Interface atualizando em tempo real

#### 9.2 **Verificar Banco de Dados**
```bash
# Conectar ao PostgreSQL
docker exec -it server-ocpp-db-1 psql -U postgres -d citrine

# Verificar transações
SELECT * FROM "Transactions" ORDER BY "createdAt" DESC LIMIT 5;

# Verificar carregadores
SELECT * FROM "ChargingStations" WHERE "id" = 'cp001';
```

---

## 🚨 Solução de Problemas

### **Problema: Carregador não conecta**
```bash
# Verificar configuração
docker exec everest-ac-demo-manager-1 cat /ext/dist/etc/everest/config-citrineos-ocpp201.yaml

# Reiniciar EVerest
./setup-everest-citrineos.sh
```

### **Problema: Transação não inicia**
1. Verificar se carregador está online
2. Verificar autorização RFID
3. Verificar logs de erro

### **Problema: Interface não atualiza**
1. Recarregar página
2. Verificar conexão WebSocket
3. Verificar logs do frontend

---

## 📊 Métricas de Sucesso

### **Indicadores de Funcionamento**
- ✅ **Conexão**: Carregador aparece como online
- ✅ **Autorização**: RFID aceito/rejeitado corretamente
- ✅ **Transações**: Início/fim funcionando
- ✅ **Dados**: Informações salvas no banco
- ✅ **Interface**: Atualizações em tempo real

### **Logs Esperados**
```
[INFO] OCPP201 :: Connected to Central System
[INFO] OCPP201 :: Boot notification sent
[INFO] OCPP201 :: Transaction started
[INFO] OCPP201 :: Transaction stopped
```

---

## 🎉 Conclusão

Após seguir este guia, você terá:
- ✅ Sistema CPMS completo funcionando
- ✅ Simulador EVerest conectado
- ✅ Testes de transação realizados
- ✅ Interface funcionando perfeitamente
- ✅ Dados sendo salvos corretamente

**Seu sistema Íon CPMS estará pronto para testes avançados e desenvolvimento!** 🚗⚡

---

## 📞 Suporte

Para problemas ou dúvidas:
1. Verifique os logs dos serviços
2. Execute os scripts de teste
3. Consulte a documentação do CitrineOS
4. Verifique as configurações de rede
