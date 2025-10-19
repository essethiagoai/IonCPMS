// CitrineOS Configuration
// This file is used for dynamic configuration in production
// For development, configuration is handled by .env files

window.APP_CONFIG = window.APP_CONFIG || {
  // Default configuration values
  VITE_APP_NAME: 'CitrineOS',
  VITE_GOOGLE_MAPS_API_KEY: 'AIzaSyBp8EbkA88gKWO8RHApudo9eoVJXhAztBk',
  VITE_GOOGLE_MAPS_LOCATION_PICKER_MAP_ID: 'citrineos-location-picker',
  VITE_GOOGLE_MAPS_OVERVIEW_MAP_ID: 'citrineos-overview',
  VITE_ADMIN_EMAIL: 'admin@citrineos.com',
  VITE_ADMIN_PASSWORD: 'CitrineOS!',
  VITE_API_URL: 'http://localhost:8090/v1/graphql',
  VITE_WS_URL: 'ws://localhost:8090/v1/graphql',
  VITE_HASURA_URL: 'http://localhost:8090/v1/graphql',
  VITE_HASURA_WS_URL: 'ws://localhost:8090/v1/graphql'
};
