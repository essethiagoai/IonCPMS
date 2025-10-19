#!/bin/bash

echo "🛠️ Criando Simulador OCPP Simples para Testes..."
echo ""

# Criar diretório para o simulador
mkdir -p ocpp-simulator
cd ocpp-simulator

echo "📝 Criando simulador OCPP básico..."

# Criar package.json
cat > package.json << 'EOF'
{
  "name": "ocpp-simulator",
  "version": "1.0.0",
  "description": "Simulador OCPP para testes com CitrineOS",
  "main": "simulator.js",
  "scripts": {
    "start": "node simulator.js",
    "test": "node test-transactions.js"
  },
  "dependencies": {
    "ws": "^8.14.2",
    "uuid": "^9.0.1"
  }
}
EOF

# Criar simulador básico
cat > simulator.js << 'EOF'
const WebSocket = require('ws');
const { v4: uuidv4 } = require('uuid');

class OCPPSimulator {
  constructor(centralSystemUrl = 'ws://localhost:8080') {
    this.centralSystemUrl = centralSystemUrl;
    this.ws = null;
    this.chargerId = 'SIMULATOR_001';
    this.transactionId = null;
    this.isCharging = false;
    this.energyDelivered = 0;
    this.meterValue = 0;
  }

  connect() {
    console.log(`🔌 Conectando ao CitrineOS: ${this.centralSystemUrl}`);
    
    this.ws = new WebSocket(this.centralSystemUrl);
    
    this.ws.on('open', () => {
      console.log('✅ Conectado ao CitrineOS');
      this.sendBootNotification();
    });
    
    this.ws.on('message', (data) => {
      this.handleMessage(JSON.parse(data));
    });
    
    this.ws.on('close', () => {
      console.log('❌ Conexão fechada');
      setTimeout(() => this.connect(), 5000); // Reconectar em 5s
    });
    
    this.ws.on('error', (error) => {
      console.error('❌ Erro na conexão:', error.message);
    });
  }

  sendBootNotification() {
    const bootNotification = [
      2, // CALL
      uuidv4(), // MessageId
      "BootNotification", // Action
      {
        chargingStation: {
          model: "Simulator Model",
          vendorName: "Test Vendor"
        },
        reason: "PowerUp"
      }
    ];
    
    this.sendMessage(bootNotification);
  }

  sendMessage(message) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
      console.log('📤 Enviado:', message[2]);
    }
  }

  handleMessage(message) {
    const [messageType, messageId, action, payload] = message;
    
    console.log('📥 Recebido:', action);
    
    switch (action) {
      case 'BootNotification':
        this.handleBootNotificationResponse(messageId, payload);
        break;
      case 'StartTransaction':
        this.handleStartTransaction(messageId, payload);
        break;
      case 'StopTransaction':
        this.handleStopTransaction(messageId, payload);
        break;
      case 'RequestStartTransaction':
        this.handleRequestStartTransaction(messageId, payload);
        break;
      case 'RequestStopTransaction':
        this.handleRequestStopTransaction(messageId, payload);
        break;
      default:
        console.log('⚠️ Ação não implementada:', action);
    }
  }

  handleBootNotificationResponse(messageId, payload) {
    const response = [
      3, // CALLRESULT
      messageId,
      {
        currentTime: new Date().toISOString(),
        interval: 300,
        status: "Accepted"
      }
    ];
    
    this.sendMessage(response);
    
    // Enviar status inicial
    setTimeout(() => this.sendStatusNotification(), 1000);
  }

  sendStatusNotification() {
    const statusNotification = [
      2, // CALL
      uuidv4(),
      "StatusNotification",
      {
        connectorId: 1,
        errorCode: "NoError",
        status: this.isCharging ? "Charging" : "Available",
        timestamp: new Date().toISOString()
      }
    ];
    
    this.sendMessage(statusNotification);
  }

  handleStartTransaction(messageId, payload) {
    this.transactionId = uuidv4();
    this.isCharging = true;
    this.energyDelivered = 0;
    this.meterValue = 0;
    
    const response = [
      3, // CALLRESULT
      messageId,
      {
        transactionId: this.transactionId,
        idTokenInfo: {
          status: "Accepted"
        }
      }
    ];
    
    this.sendMessage(response);
    
    // Simular carregamento
    this.simulateCharging();
  }

  handleStopTransaction(messageId, payload) {
    this.isCharging = false;
    
    const response = [
      3, // CALLRESULT
      messageId,
      {
        idTokenInfo: {
          status: "Accepted"
        }
      }
    ];
    
    this.sendMessage(response);
    
    // Enviar status final
    setTimeout(() => this.sendStatusNotification(), 1000);
  }

  handleRequestStartTransaction(messageId, payload) {
    // Simular autorização
    const response = [
      3, // CALLRESULT
      messageId,
      {
        status: "Accepted"
      }
    ];
    
    this.sendMessage(response);
  }

  handleRequestStopTransaction(messageId, payload) {
    // Simular parada
    const response = [
      3, // CALLRESULT
      messageId,
      {
        status: "Accepted"
      }
    ];
    
    this.sendMessage(response);
  }

  simulateCharging() {
    if (!this.isCharging) return;
    
    // Simular consumo de energia
    this.energyDelivered += 0.1; // 0.1 kWh por segundo
    this.meterValue += 100; // 100 Wh por segundo
    
    // Enviar meter values
    const meterValues = [
      2, // CALL
      uuidv4(),
      "MeterValues",
      {
        connectorId: 1,
        transactionId: this.transactionId,
        meterValue: [
          {
            timestamp: new Date().toISOString(),
            sampledValue: [
              {
                value: this.meterValue.toString(),
                context: "Sample.Periodic",
                format: "Raw",
                measurand: "Energy.Active.Import.Register",
                unit: "Wh"
              }
            ]
          }
        ]
      }
    ];
    
    this.sendMessage(meterValues);
    
    // Continuar simulação
    setTimeout(() => this.simulateCharging(), 1000);
  }

  // Métodos para controle manual
  startCharging() {
    if (!this.isCharging) {
      this.transactionId = uuidv4();
      this.isCharging = true;
      this.sendStatusNotification();
      this.simulateCharging();
      console.log('🔋 Iniciando carregamento simulado');
    }
  }

  stopCharging() {
    if (this.isCharging) {
      this.isCharging = false;
      this.sendStatusNotification();
      console.log('⏹️ Parando carregamento simulado');
    }
  }
}

// Inicializar simulador
const simulator = new OCPPSimulator();
simulator.connect();

// Controles via console
console.log('\n🎮 Controles disponíveis:');
console.log('  simulator.startCharging() - Iniciar carregamento');
console.log('  simulator.stopCharging() - Parar carregamento');
console.log('  Ctrl+C - Sair\n');

// Expor para uso global
global.simulator = simulator;
EOF

# Criar script de teste
cat > test-transactions.js << 'EOF'
const { OCPPSimulator } = require('./simulator');

console.log('🧪 Testando Funcionalidades Transacionais...\n');

// Simular cenários de teste
async function runTests() {
  const simulator = new OCPPSimulator();
  
  console.log('1. 🔌 Teste de Conexão');
  simulator.connect();
  
  setTimeout(() => {
    console.log('2. 🔋 Teste de Início de Transação');
    simulator.startCharging();
  }, 5000);
  
  setTimeout(() => {
    console.log('3. ⏹️ Teste de Parada de Transação');
    simulator.stopCharging();
  }, 15000);
  
  setTimeout(() => {
    console.log('4. ✅ Testes Concluídos');
    process.exit(0);
  }, 20000);
}

runTests();
EOF

echo "✅ Simulador OCPP criado!"
echo ""
echo "📦 Para instalar dependências:"
echo "   cd ocpp-simulator && npm install"
echo ""
echo "🚀 Para executar o simulador:"
echo "   cd ocpp-simulator && npm start"
echo ""
echo "🧪 Para executar testes:"
echo "   cd ocpp-simulator && npm test"
echo ""
echo "💡 O simulador irá:"
echo "   - Conectar ao CitrineOS via WebSocket"
echo "   - Simular um carregador OCPP"
echo "   - Enviar eventos de transação"
echo "   - Simular consumo de energia"
echo "   - Responder a comandos do CSMS"
