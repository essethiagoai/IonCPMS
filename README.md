# Íon CPMS - CitrineOS Setup

Este projeto implementa um Charge Point Management System (CPMS) para a empresa Íon utilizando o CitrineOS como base.

## 🚀 Início Rápido

### Pré-requisitos

Antes de executar o setup, certifique-se de ter instalado:

1. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (gerenciador de pacotes para macOS)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Node.js** (versão 18 ou superior)
   ```bash
   brew install node
   ```

4. **Docker Desktop**
   - Baixe em: https://www.docker.com/products/docker-desktop/
   - Instale e inicie o Docker Desktop

### Instalação Automatizada

Execute o script de setup automatizado:

```bash
./setup-citrineos.sh
```

Este script irá:
- ✅ Verificar todos os pré-requisitos
- 📥 Clonar o repositório CitrineOS
- 🐳 Iniciar todos os serviços com Docker Compose
- 🎉 Configurar o ambiente completo

### Verificação dos Serviços

Para verificar se todos os serviços estão funcionando:

```bash
./check-services.sh
```

### Instalação da Operator UI (Interface Web)

Para instalar e configurar a interface web de gerenciamento:

```bash
./setup-operator-ui.sh
```

Este script irá:
- ✅ Clonar o repositório da Operator UI
- 📦 Instalar todas as dependências
- ⚙️ Configurar as variáveis de ambiente
- 🚀 Iniciar a interface web automaticamente

## 📋 Serviços Disponíveis

Após o setup, os seguintes serviços estarão disponíveis:

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **HTTP Server** | http://localhost:8080 | Servidor principal da API |
| **API Documentation** | http://localhost:8080/docs | Documentação interativa da API |
| **Operator UI** | http://localhost:3000 | Interface web para gerenciamento |
| **WebSocket (Não Seguro)** | ws://localhost:8081 | Conexão OCPP WebSocket |
| **WebSocket (Seguro)** | wss://localhost:8082 | Conexão OCPP WebSocket segura |
| **PostgreSQL** | postgresql://citrine:citrine@localhost:5432/citrine | Banco de dados |
| **RabbitMQ** | amqp://guest:guest@localhost:5672 | Message broker |
| **RabbitMQ Management** | http://localhost:15672 | Interface de gerenciamento do RabbitMQ |

## 🛠️ Comandos Úteis

### Gerenciamento de Serviços

```bash
# Iniciar serviços
cd citrineos-core/Server
docker compose up -d

# Parar serviços
docker compose down

# Reiniciar serviços
docker compose restart

# Ver logs em tempo real
docker compose logs -f

# Ver status dos containers
docker compose ps
```

### Teste de Conectividade

Para testar a conectividade OCPP, você pode usar o `wscat`:

```bash
# Instalar wscat (se não tiver)
npm install -g wscat

# Testar BootNotification
wscat -c ws://localhost:8081 -x '[
  2,
  "15106be4-57ca-11ee-8c99-0242ac120003",
  "BootNotification",
  {
    "reason": "PowerUp",
    "chargingStation": {
      "model": "SingleSocketCharger",
      "vendorName": "VendorX"
    }
  }
]'
```

## 🔧 Solução de Problemas

### Docker não está rodando
```bash
# Iniciar Docker Desktop manualmente ou via linha de comando
open -a Docker
```

### Porta já em uso
```bash
# Verificar quais processos estão usando as portas
lsof -i :8080
lsof -i :8081
lsof -i :8082
lsof -i :5432
lsof -i :5672
```

### Limpar containers e volumes
```bash
cd citrineos-core/Server
docker compose down -v
docker system prune -f
```

## 📚 Documentação Adicional

- [CitrineOS Documentation](https://citrineos.github.io/latest/)
- [OCPP 2.0.1 Specification](https://www.openchargealliance.org/protocols/ocpp-201/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🌍 Configuração de Países

O CitrineOS suporta múltiplos países e estados. Por padrão, estão disponíveis:

- **USA** (Estados Unidos) - 50 estados
- **Canada** - 13 províncias/territórios  
- **Brazil** (Brasil) - 27 estados ✅ *Adicionado para Íon CPMS*

### Adicionando Novos Países

Para adicionar um novo país:

1. **Edite o arquivo**: `citrineos-operator-ui/src/pages/locations/country.state.data.ts`
2. **Adicione ao enum Country**:
   ```typescript
   export enum Country {
     USA = 'USA',
     Canada = 'Canada',
     Brazil = 'Brazil',
     SeuPais = 'SeuPais', // ← Adicione aqui
   }
   ```
3. **Adicione os estados**:
   ```typescript
   export const countryStateData: { [key: string]: string[] } = {
     // ... países existentes
     [Country.SeuPais]: [
       'Estado1',
       'Estado2',
       'Estado3',
     ],
   };
   ```
4. **Reinicie a Operator UI**

### Script Automatizado

Use o script `./add-country.sh` para facilitar a adição:

```bash
./add-country.sh "Argentina" "Buenos Aires,Córdoba,Santa Fe"
```

## 🗺️ Configuração do Google Maps

Para habilitar os mapas interativos na interface:

### 1. Criar API Key do Google Maps

1. **Acesse**: https://console.cloud.google.com/
2. **Crie um projeto** ou selecione um existente
3. **Habilite as APIs**:
   - Maps JavaScript API
   - Geocoding API
   - Places API (opcional)
4. **Crie uma API key**: APIs & Services → Credentials → Create Credentials → API key
5. **Configure restrições** (recomendado):
   - Application restrictions: HTTP referrers
   - Adicione: `http://localhost:*`, `https://localhost:*`
   - API restrictions: Restrict key → selecione apenas as APIs necessárias

### 2. Configurar no CitrineOS

**Opção 1: Script Automatizado**
```bash
./configure-google-maps.sh "sua_api_key_aqui"
```

**Opção 2: Manual**
1. Edite o arquivo: `citrineos-operator-ui/.env`
2. Substitua: `VITE_GOOGLE_MAPS_API_KEY=SUA_API_KEY_AQUI`
3. Reinicie o servidor

### 3. Verificar Funcionamento

- Acesse a Operator UI
- Vá para Locations → Create Location
- O mapa deve carregar corretamente
- Você pode selecionar localizações clicando no mapa

## 🐛 Correções Aplicadas

### Campos de Latitude e Longitude

**Problema**: Os campos de latitude e longitude estavam sincronizados incorretamente - alterar um campo alterava automaticamente o outro.

**Solução**: Separados os campos com nomes únicos (`latitude` e `longitude`) para funcionarem independentemente.

**Teste**: Execute `./test-location-form.sh` para verificar se a correção funcionou.

## 🆘 Suporte

Se encontrar problemas durante a instalação ou configuração:

1. Verifique se todos os pré-requisitos estão instalados
2. Execute `./check-services.sh` para diagnosticar problemas
3. Verifique os logs com `docker compose logs -f`
4. Consulte a documentação oficial do CitrineOS

---

**Desenvolvido para Íon CPMS** 🚗⚡
