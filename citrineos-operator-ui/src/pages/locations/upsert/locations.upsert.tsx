// SPDX-FileCopyrightText: 2025 Contributors to the CitrineOS Project
//
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  LOCATIONS_CREATE_MUTATION,
  LOCATIONS_EDIT_MUTATION,
  LOCATIONS_GET_QUERY,
} from '../queries';
import {
  App,
  Button,
  Col,
  Flex,
  Form,
  Input,
  InputNumber,
  Row,
  Select,
  Upload,
} from 'antd';
import { useForm } from '@refinedev/antd';
import { Country, countryStateData } from '../country.state.data';
import { MapLocationPicker } from '../../../components/map';
import { GeoPoint, PointProps } from '@util/GeoPoint';
import { geocodeAddress } from '@util/geocoding';
import { getSerializedValues } from '@util/middleware';
import { LocationDto } from '../../../dtos/location.dto';
import {
  BaseKey,
  CanAccess,
  useNavigation,
  useUpdateMany,
} from '@refinedev/core';
import { UploadOutlined } from '@ant-design/icons';
import { ArrowLeftIcon } from '../../../components/icons/arrow.left.icon';
import { SelectedChargingStations } from './selected.charging.stations';
import { useParams } from 'react-router-dom';
import { getPlainToInstanceOptions } from '@util/tables';
import { AccessDeniedFallback, ActionType, ResourceType } from '@util/auth';
import config from '@util/config';
import {
  ChargingStationDtoProps,
  IChargingStationDto,
  ILocationDto,
  LocationDtoProps,
  LocationFacilityType,
  LocationParkingType,
} from '@citrineos/base';
import { MenuSection } from '../../../components/main-menu/main.menu';

export const LocationsUpsert = () => {
  const params: any = useParams<{ id: string }>();
  const locationId = params.id ? params.id : undefined;
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [latitude, setLatitude] = useState<number | null>(null);
  const [longitude, setLongitude] = useState<number | null>(null);
  const [mapCenter, setMapCenter] = useState<{ lat: number; lng: number }>({ lat: 39.8283, lng: -98.5795 });
  const [isUserInteracting, setIsUserInteracting] = useState(false);
  const formValuesRef = useRef<Record<string, any>>({});
  const { message } = App.useApp();
  const { replace, goBack } = useNavigation();
  const { mutate } = useUpdateMany();

  const { form, formProps, query } = useForm<ILocationDto>({
    resource: ResourceType.LOCATIONS,
    id: locationId,
    queryOptions: {
      ...getPlainToInstanceOptions(LocationDto, true),
      enabled: !!locationId,
    },
    redirect: false,
    successNotification: false,
    onMutationSuccess: async (locationResponse) => {
      const currentStations =
        formValuesRef.current[LocationDtoProps.chargingPool] || [];
      const prevStations =
        form.getFieldValue(LocationDtoProps.chargingPool) || [];

      const currentIds = new Set(
        currentStations.map((cs: IChargingStationDto) => cs.id),
      );
      const prevIds = new Set(
        prevStations.map((cs: IChargingStationDto) => cs.id),
      );
      const addedIds = [...currentIds].filter(
        (id) => !prevIds.has(id),
      ) as BaseKey[];
      const removedIds = [...prevIds].filter(
        (id) => !currentIds.has(id),
      ) as BaseKey[];
      const updateOperations = [];
      if (addedIds.length > 0) {
        updateOperations.push(
          new Promise((resolve, reject) => {
            mutate(
              {
                successNotification: false,
                resource: ResourceType.CHARGING_STATIONS,
                mutationMode: 'pessimistic',
                ids: addedIds,
                values: {
                  [ChargingStationDtoProps.locationId]:
                    locationResponse.data.id,
                },
              },
              {
                onSuccess: resolve,
                onError: reject,
              },
            );
          }),
        );
      }
      if (removedIds.length > 0) {
        updateOperations.push(
          new Promise((resolve, reject) => {
            mutate(
              {
                successNotification: false,
                resource: ResourceType.CHARGING_STATIONS,
                mutationMode: 'pessimistic',
                ids: removedIds,
                values: { [ChargingStationDtoProps.locationId]: null },
              },
              {
                onSuccess: resolve,
                onError: reject,
              },
            );
          }),
        );
      }
      try {
        await Promise.all(updateOperations);
        message.success('Location updated successfully').then();
      } catch (_error) {
        message.error('Failed to update charging stations').then();
      } finally {
        const newId = locationResponse.data.id;
        replace(`/${MenuSection.LOCATIONS}/${newId}`);
        setIsSubmitting(false);
      }
    },
    onMutationError: () => {
      message.error('Failed to create location').then();
      setIsSubmitting(false);
    },
    meta: {
      gqlQuery: LOCATIONS_GET_QUERY,
      gqlMutation: locationId
        ? LOCATIONS_EDIT_MUTATION
        : LOCATIONS_CREATE_MUTATION,
    },
  });

  useEffect(() => {
    form?.setFieldsValue({
      [LocationDtoProps.facilities]: query?.data?.data?.facilities,
    });
    
    // Atualizar coordenadas quando dados são carregados (especialmente para edição)
    if (query?.data?.data?.coordinates?.coordinates) {
      const coords = query.data.data.coordinates.coordinates;
      const [lng, lat] = coords;
      
      // Atualizar formulário
      form.setFieldsValue({
        [LocationDtoProps.coordinates]: {
          type: 'Point',
          coordinates: [lng, lat],
        },
      });
      
      // Atualizar estados locais apenas se não há valores ou se são diferentes
      // E se o usuário não está interagindo com o mapa
      if (!isUserInteracting && (latitude === null || longitude === null || 
          Math.abs(latitude - lat) > 0.000001 || 
          Math.abs(longitude - lng) > 0.000001)) {
        console.log('Carregando dados iniciais:', { lat, lng });
        setLongitude(lng);
        setLatitude(lat);
        setMapCenter({ lat, lng });
      }
    }
    return;
  }, [query?.data?.data]);

  // Sincronizar estados locais com o formulário quando mudam
  useEffect(() => {
    if (latitude !== null && longitude !== null) {
      console.log('useEffect sincronizando coordenadas:', { latitude, longitude });
      form.setFieldsValue({
        [LocationDtoProps.coordinates]: {
          type: 'Point',
          coordinates: [longitude, latitude],
        },
      });
    }
  }, [latitude, longitude, form]);

  const onFinish = () => {
    try {
      formValuesRef.current = form.getFieldsValue(true);
      if (isSubmitting) return;
      setIsSubmitting(true);
      const input = { ...formValuesRef.current };
      delete input[LocationDtoProps.chargingPool];
      const newItem: any = getSerializedValues(input, LocationDto);
      if (!locationId) {
        newItem.tenantId = config.tenantId;
      }
      formProps.onFinish?.(newItem);
    } catch (error) {
      message.error('Failed to submit form').then();
      setIsSubmitting(false);
    }
  };

  const handleLocationSelect = (point: GeoPoint) => {
    console.log('handleLocationSelect chamado com:', { lat: point.latitude, lng: point.longitude });
    
    setIsUserInteracting(true);
    setLongitude(point.longitude);
    setLatitude(point.latitude);
    setMapCenter({ lat: point.latitude, lng: point.longitude });
    
    form?.setFieldsValue({
      coordinates: {
        type: 'Point',
        coordinates: [point.longitude, point.latitude],
      },
    });
    
    console.log('Estados locais atualizados:', { latitude: point.latitude, longitude: point.longitude });
  };

  // Função para geocodificar endereço e atualizar o mapa
  const geocodeAndUpdateMap = async (address: string) => {
    if (!address || address.trim() === '') return;
    
    try {
      console.log('Geocodificando endereço:', address);
      const result = await geocodeAddress(address);
      const lat = result.geometry.location.lat;
      const lng = result.geometry.location.lng;
      
      console.log('Coordenadas encontradas:', { lat, lng });
      
      setIsUserInteracting(true);
      setLatitude(lat);
      setLongitude(lng);
      setMapCenter({ lat, lng });
      
      form?.setFieldsValue({
        coordinates: {
          type: 'Point',
          coordinates: [lng, lat],
        },
      });
      
      console.log('Formulário atualizado com coordenadas:', [lng, lat]);
    } catch (error) {
      console.error('Erro ao geocodificar endereço:', error);
    }
  };

  return (
    <CanAccess
      resource={ResourceType.LOCATIONS}
      action={ActionType.EDIT}
      fallback={<AccessDeniedFallback />}
      params={{ id: locationId }}
    >
      <Form
        {...formProps}
        layout="vertical"
        onFinish={onFinish}
        data-testid="locations-create-form"
      >
        <Flex vertical gap={16}>
          <Flex gap={12} align={'center'}>
            <ArrowLeftIcon
              style={{
                cursor: 'pointer',
              }}
              onClick={() => goBack()}
            />
            <h3>{locationId ? 'Edit' : 'Create'} Location</h3>
          </Flex>
          <Flex gap={16}>
            <Flex vertical flex={1}>
              <Form.Item
                key={LocationDtoProps.name}
                label="Name"
                name={LocationDtoProps.name}
                rules={[
                  { required: true, message: 'Please select location name' },
                ]}
                data-testid={LocationDtoProps.name}
              >
                <Input />
              </Form.Item>
              <Form.Item
                key={LocationDtoProps.address}
                label="Address"
                name={LocationDtoProps.address}
                rules={[
                  { required: true, message: 'Please enter location address' },
                ]}
                data-testid={LocationDtoProps.address}
              >
                <Input 
                  placeholder="Enter address"
                  onBlur={(e) => {
                    const address = e.target.value;
                    if (address && address.trim() !== '') {
                      geocodeAndUpdateMap(address);
                    }
                  }}
                />
              </Form.Item>
              <Form.Item>
                <Button 
                  type="primary" 
                  onClick={() => {
                    const address = form.getFieldValue(LocationDtoProps.address);
                    if (address && address.trim() !== '') {
                      geocodeAndUpdateMap(address);
                    }
                  }}
                >
                  📍 Find on Map
                </Button>
              </Form.Item>
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.city}
                    label="City"
                    name={LocationDtoProps.city}
                    rules={[
                      { required: true, message: 'Please enter location city' },
                    ]}
                    data-testid={LocationDtoProps.city}
                  >
                    <Input />
                  </Form.Item>
                </Col>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.postalCode}
                    label="Postal Code"
                    name={LocationDtoProps.postalCode}
                    rules={[
                      {
                        required: true,
                        message: 'Please enter location postal code',
                      },
                    ]}
                    data-testid={LocationDtoProps.postalCode}
                  >
                    <Input />
                  </Form.Item>
                </Col>
              </Row>
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.state}
                    label="State"
                    name={LocationDtoProps.state}
                    rules={[
                      {
                        required: true,
                        message: 'Please select location state',
                      },
                    ]}
                    data-testid={LocationDtoProps.state}
                  >
                    <Select placeholder="Select a state" allowClear>
                      {countryStateData[
                        form.getFieldValue(LocationDtoProps.country) ||
                          Country.USA
                      ]?.map((state) => (
                        <Select.Option key={state} value={state}>
                          {state}
                        </Select.Option>
                      )) || []}
                    </Select>
                  </Form.Item>
                </Col>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.country}
                    label="Country"
                    name={LocationDtoProps.country}
                    rules={[
                      {
                        required: true,
                        message: 'Please select location country',
                      },
                    ]}
                    data-testid={LocationDtoProps.country}
                  >
                    <Select placeholder="Select a country" allowClear>
                      {Object.keys(Country).map((country) => (
                        <Select.Option key={country} value={country}>
                          {country}
                        </Select.Option>
                      ))}
                    </Select>
                  </Form.Item>
                </Col>
              </Row>
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    label="Latitude"
                    key={'Latitude'}
                    data-testid={'Latitude'}
                  >
                    <Input
                      placeholder="Click map or enter manually"
                      value={latitude !== null ? latitude.toString() : ''}
                      onChange={(e) => {
                        const value = e.target.value;
                        if (value === '') {
                          setLatitude(null);
                        } else {
                          // Permitir entrada de texto, validar apenas no onBlur
                          setLatitude(value as any);
                        }
                      }}
                      onBlur={() => {
                        // Validar e converter para número quando perde o foco
                        if (latitude !== null) {
                          const numValue = parseFloat(latitude.toString());
                          if (!isNaN(numValue)) {
                            setLatitude(numValue);
                          } else {
                            setLatitude(null);
                          }
                        }
                      }}
                    />
                  </Form.Item>
                </Col>
                <Col span={12}>
                  <Form.Item
                    label="Longitude"
                    key={'Longitude'}
                    data-testid={'Longitude'}
                  >
                    <Input
                      placeholder="Click map or enter manually"
                      value={longitude !== null ? longitude.toString() : ''}
                      onChange={(e) => {
                        const value = e.target.value;
                        if (value === '') {
                          setLongitude(null);
                        } else {
                          // Permitir entrada de texto, validar apenas no onBlur
                          setLongitude(value as any);
                        }
                      }}
                      onBlur={() => {
                        // Validar e converter para número quando perde o foco
                        if (longitude !== null) {
                          const numValue = parseFloat(longitude.toString());
                          if (!isNaN(numValue)) {
                            setLongitude(numValue);
                          } else {
                            setLongitude(null);
                          }
                        }
                      }}
                    />
                  </Form.Item>
                </Col>
              </Row>
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.timeZone}
                    label="Timezone"
                    name={LocationDtoProps.timeZone}
                    data-testid={LocationDtoProps.timeZone}
                  >
                    <Input />
                  </Form.Item>
                </Col>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.parkingType}
                    label="Parking Type"
                    name={LocationDtoProps.parkingType}
                    data-testid={LocationDtoProps.parkingType}
                  >
                    <Select placeholder="Select a parking type" allowClear>
                      {Object.keys(LocationParkingType).map((parkingType) => (
                        <Select.Option key={parkingType} value={parkingType}>
                          {parkingType}
                        </Select.Option>
                      ))}
                    </Select>
                  </Form.Item>
                </Col>
              </Row>
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    key={LocationDtoProps.facilities}
                    label="Facilities"
                    name={LocationDtoProps.facilities}
                    data-testid={LocationDtoProps.facilities}
                  >
                    <Select
                      mode="tags"
                      placeholder="Select facilities"
                      allowClear
                    >
                      {Object.keys(LocationFacilityType).map((facility) => (
                        <Select.Option key={facility} value={facility}>
                          {facility}
                        </Select.Option>
                      ))}
                    </Select>
                  </Form.Item>
                </Col>
              </Row>
              <Row style={{ marginTop: '10px' }}>
                <Col>
                  <Row style={{ marginBottom: '10px' }}>
                    <Upload>
                      <Button icon={<UploadOutlined />}>Upload Image</Button>
                    </Upload>
                  </Row>
                  <Row>
                    <Form.Item>
                      <Button
                        type="primary"
                        htmlType="submit"
                        data-testid="locations-create-form-submit"
                        loading={isSubmitting}
                        disabled={isSubmitting}
                      >
                        Submit
                      </Button>
                    </Form.Item>
                  </Row>
                </Col>
              </Row>
            </Flex>
            <Flex vertical flex={1}>
              <Row>
                <strong>Please select a location</strong>
              </Row>
              <MapLocationPicker
                point={
                  latitude !== null && longitude !== null
                    ? new GeoPoint(latitude, longitude)
                    : form.getFieldValue(LocationDtoProps.coordinates)
                }
                defaultCenter={mapCenter}
                zoom={latitude !== null && longitude !== null ? 15 : 3}
                onLocationSelect={handleLocationSelect}
              />
            </Flex>
          </Flex>
          {locationId && <SelectedChargingStations form={form} />}
        </Flex>
      </Form>
    </CanAccess>
  );
};
