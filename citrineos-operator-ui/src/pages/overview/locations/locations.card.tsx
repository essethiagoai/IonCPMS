// SPDX-FileCopyrightText: 2025 Contributors to the CitrineOS Project
//
// SPDX-License-Identifier: Apache-2.0

import { Flex, Input, Card, Typography, Button } from 'antd';
import { ArrowRightIcon } from '../../../components/icons/arrow.right.icon';
import { useNavigation } from '@refinedev/core';
import { MenuSection } from '../../../components/main-menu/main.menu';
import { useSelect } from '@refinedev/antd';
import { ResourceType } from '@util/auth';
import React, { useState, useEffect } from 'react';
import { LOCATIONS_LIST_QUERY } from '../../locations/queries';
import { getLocationsFilters } from '../../locations/columns';
import { LocationsMap } from '../../locations/map/locations.map';
import { BaseDtoProps, ILocationDto } from '@citrineos/base';
import config from '@util/config';

const { Search } = Input;
const { Title, Text } = Typography;

// Componente de fallback para quando o mapa não funciona
const LocationsMapFallback = () => {
  const [showMap, setShowMap] = useState(false);
  const [mapError, setMapError] = useState(false);

  useEffect(() => {
    // Verificar se a API key do Google Maps é válida
    const apiKey = config.googleMapsApiKey;
    const isApiKeyValid = apiKey && apiKey !== 'YOUR_GOOGLE_MAPS_API_KEY' && apiKey.length > 20;
    
    if (!isApiKeyValid) {
      setMapError(true);
    }
  }, []);

  if (mapError) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100%',
        padding: '20px',
        textAlign: 'center',
        backgroundColor: '#f5f5f5',
        borderRadius: '8px'
      }}>
        <Title level={4}>🗺️ Mapa não disponível</Title>
        <Text type="secondary" style={{ marginBottom: '16px' }}>
          Para visualizar o mapa, configure uma API key válida do Google Maps.
        </Text>
        <Button 
          type="primary" 
          onClick={() => window.open('https://console.cloud.google.com/apis/credentials', '_blank')}
        >
          Configurar Google Maps API
        </Button>
      </div>
    );
  }

  if (!showMap) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100%',
        padding: '20px',
        textAlign: 'center',
        backgroundColor: '#f5f5f5',
        borderRadius: '8px'
      }}>
        <Title level={4}>🗺️ Mapa de Localizações</Title>
        <Text type="secondary" style={{ marginBottom: '16px' }}>
          Clique no botão abaixo para carregar o mapa interativo.
        </Text>
        <Button 
          type="primary" 
          onClick={() => setShowMap(true)}
        >
          Carregar Mapa
        </Button>
      </div>
    );
  }

  return <LocationsMap />;
};

export const LocationsCard = () => {
  const { push } = useNavigation();

  const { selectProps: locationsSelectProps } = useSelect<ILocationDto>({
    resource: ResourceType.LOCATIONS,
    optionLabel: (location) => location.name,
    optionValue: (location) => `${location.id}`,
    meta: {
      gqlQuery: LOCATIONS_LIST_QUERY,
      gqlVariables: {
        offset: 0,
        limit: 5,
      },
    },
    sorters: [{ field: BaseDtoProps.updatedAt, order: 'desc' }],
    pagination: { mode: 'off' },
    onSearch: (value) => getLocationsFilters(value),
  });

  return (
    <Flex
      vertical
      style={{
        height: '100%',
      }}
    >
      <Flex justify="space-between" style={{ padding: '24px 16px' }}>
        <h4>Locations</h4>
        <Flex
          className="link"
          onClick={() => push(`/${MenuSection.LOCATIONS}`)}
        >
          View all <ArrowRightIcon />
        </Flex>
      </Flex>
      {/* <Flex style={{ marginBottom: '24px', padding: '0 16px' }}>
        <Flex flex={7}>
          <AutoComplete
            className="full-width"
            onSelect={(id) => push(`/${MenuSection.TRANSACTIONS}/${id}`)}
            filterOption={false}
            placeholder="Search Transaction"
            {...locationsSelectProps}
          />
        </Flex>
        <Flex flex={3}>
          <span></span>
        </Flex>
      </Flex> */}
      <Flex
        style={{
          height: '100%',
          borderRadius: '0 0 8px 8px',
          overflow: 'hidden',
        }}
      >
        <LocationsMapFallback />
      </Flex>
    </Flex>
  );
};
