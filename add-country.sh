#!/bin/bash

# Script para adicionar novos países ao CitrineOS
# Uso: ./add-country.sh "CountryName" "State1,State2,State3"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ $# -ne 2 ]; then
    echo -e "${RED}❌ Uso: $0 \"NomeDoPais\" \"Estado1,Estado2,Estado3\"${NC}"
    echo -e "${YELLOW}Exemplo: $0 \"Argentina\" \"Buenos Aires,Córdoba,Santa Fe\"${NC}"
    exit 1
fi

COUNTRY_NAME="$1"
STATES_STRING="$2"

echo -e "${BLUE}🌍 Adicionando $COUNTRY_NAME ao CitrineOS...${NC}"

# Converter string de estados em array
IFS=',' read -ra STATES <<< "$STATES_STRING"

# Criar o enum value (remover espaços e caracteres especiais)
COUNTRY_ENUM=$(echo "$COUNTRY_NAME" | sed 's/[^a-zA-Z0-9]//g')

echo -e "${BLUE}📝 País: $COUNTRY_NAME${NC}"
echo -e "${BLUE}📝 Enum: $COUNTRY_ENUM${NC}"
echo -e "${BLUE}📝 Estados: ${#STATES[@]} estados encontrados${NC}"

# Verificar se o arquivo existe
COUNTRY_FILE="citrineos-operator-ui/src/pages/locations/country.state.data.ts"

if [ ! -f "$COUNTRY_FILE" ]; then
    echo -e "${RED}❌ Arquivo $COUNTRY_FILE não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Arquivo encontrado: $COUNTRY_FILE${NC}"

# Verificar se o país já existe
if grep -q "$COUNTRY_ENUM = '$COUNTRY_NAME'" "$COUNTRY_FILE"; then
    echo -e "${YELLOW}⚠️  País $COUNTRY_NAME já existe no arquivo${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 País $COUNTRY_NAME adicionado com sucesso!${NC}"
echo -e "${BLUE}📋 Estados incluídos:${NC}"
for state in "${STATES[@]}"; do
    echo -e "  • $state"
done

echo ""
echo -e "${YELLOW}💡 Para aplicar as mudanças:${NC}"
echo -e "1. Reinicie o servidor da Operator UI"
echo -e "2. Acesse a interface e crie uma nova localização"
echo -e "3. O país $COUNTRY_NAME estará disponível na lista"
