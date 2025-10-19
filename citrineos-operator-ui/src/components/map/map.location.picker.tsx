// SPDX-FileCopyrightText: 2025 Contributors to the CitrineOS Project
//
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useState } from 'react';
import {
  APIProvider,
  Map,
  AdvancedMarker,
  MapMouseEvent,
  useMap,
  useApiLoadingStatus,
  APILoadingStatus,
} from '@vis.gl/react-google-maps';
import config from '@util/config';
import { GeoPoint } from '@util/GeoPoint';
import { LocationPickerMapProps } from './types';
import { MarkerIconCircle } from './marker.icons';
import './style.scss';

const apiKey = config.googleMapsApiKey;

// A wrapper component that has access to the map context
const MarkerWithMap = ({
  selectedLocation,
}: {
  selectedLocation: GeoPoint;
}) => {
  const map = useMap();
  const [latLng, setLatLng] = useState<google.maps.LatLng | null>(null);

  useEffect(() => {
    // Only create the LatLng object when we have both the map and selectedLocation
    if (map && selectedLocation && selectedLocation) {
      // The google namespace is available once the map is loaded
      const position = new google.maps.LatLng({
        lat: selectedLocation.latitude,
        lng: selectedLocation.longitude,
      });
      setLatLng(position);
    }
  }, [map, selectedLocation]);

  if (!latLng) return null;

  return (
    <AdvancedMarker position={latLng}>
      <MarkerIconCircle
        fillColor="var(--primary-color-3)"
        style={{
          width: '40px',
          height: '40px',
        }}
      />
    </AdvancedMarker>
  );
};

/**
 * MapLocationPicker component that allows selecting a location on the map
 */
export const MapLocationPicker: React.FC<LocationPickerMapProps> = ({
  point,
  defaultCenter = { lat: 36.7783, lng: -119.4179 },
  zoom = 10,
  onLocationSelect,
}) => {
  // Track if map is fully initialized and ready for markers
  const [mapFullyInitialized, setMapFullyInitialized] = useState(false);
  const status = useApiLoadingStatus();
  const [selectedLocation, setSelectedLocation] = useState<GeoPoint | null>(
    null,
  );

  useEffect(() => {
    if (status === APILoadingStatus.LOADED) {
      // Small delay to ensure the map is fully rendered bc google maps has issues
      const timer = setTimeout(() => {
        setMapFullyInitialized(true);
      }, 1000);

      return () => clearTimeout(timer);
    } else {
      setMapFullyInitialized(false);
    }
  }, [status]);

  useEffect(() => {
    if (point !== undefined) {
      setSelectedLocation(point);
    }
  }, [point]);

  const handleMapClick = (e: MapMouseEvent) => {
    if (e.detail.latLng) {
      const lat = e.detail.latLng.lat;
      const lng = e.detail.latLng.lng;
      const point = new GeoPoint(lat, lng);
      setSelectedLocation(point);
      onLocationSelect(point);
    }
  };

  // Check if API key is valid (not the default placeholder)
  const isApiKeyValid = apiKey && apiKey !== 'YOUR_GOOGLE_MAPS_API_KEY' && apiKey.length > 20;

  return (
    <div className="map-wrapper">
      {isApiKeyValid ? (
        <APIProvider apiKey={apiKey}>
          <Map
            {...(config.googleMapsLocationPickerMapId && { mapId: config.googleMapsLocationPickerMapId })}
            defaultCenter={defaultCenter}
            defaultZoom={zoom}
            onClick={handleMapClick}
            gestureHandling="cooperative"
            disableDefaultUI={false}
            zoomControl={true}
            fullscreenControl={false}
          >
            {mapFullyInitialized && selectedLocation && (
              <MarkerWithMap selectedLocation={selectedLocation} />
            )}
          </Map>
        </APIProvider>
      ) : (
        <div style={{ 
          padding: '20px', 
          textAlign: 'center', 
          backgroundColor: '#f5f5f5', 
          borderRadius: '8px',
          border: '1px solid #ddd',
          minHeight: '300px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center'
        }}>
          <h3>Seletor de Localização não disponível</h3>
          <p>Para usar o seletor de mapa, configure uma API key válida do Google Maps.</p>
          <p><strong>Localização atual:</strong></p>
          <p>Latitude: {selectedLocation?.latitude || 'N/A'}</p>
          <p>Longitude: {selectedLocation?.longitude || 'N/A'}</p>
        </div>
      )}
    </div>
  );
};
