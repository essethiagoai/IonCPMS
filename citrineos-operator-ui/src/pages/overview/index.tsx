// SPDX-FileCopyrightText: 2025 Contributors to the CitrineOS Project
//
// SPDX-License-Identifier: Apache-2.0

import React, { Suspense } from 'react';
import { Route, Routes } from 'react-router-dom';
import { Card, Flex, Spin, Alert } from 'antd';
import { OnlineStatusCard } from './online-status/online.status.card';
import { ChargerActivityCard } from './charger-activity/charger.activity.card';
import { PluginSuccessRateCard } from './plugin-success-rate/plugin.success.rate.card';
import { LocationsCard } from './locations/locations.card';
import { ActiveTransactionsCard } from './active-transactions/active.transactions.card';
import { FaultedChargersCard } from './faulted-chargers/faulted.chargers.card';
import './style.scss';

// Componente de fallback para cards com erro
const CardWithErrorBoundary = ({ children, title }: { children: React.ReactNode; title: string }) => {
  return (
    <Suspense fallback={<Spin />}>
      <ErrorBoundary title={title}>
        {children}
      </ErrorBoundary>
    </Suspense>
  );
};

// Error Boundary simples
class ErrorBoundary extends React.Component<{ children: React.ReactNode; title: string }, { hasError: boolean }> {
  constructor(props: { children: React.ReactNode; title: string }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error(`Erro no card ${this.props.title}:`, error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <Alert
            message={`Erro no ${this.props.title}`}
            description="Houve um problema ao carregar este componente. Tente recarregar a página."
            type="warning"
            showIcon
          />
        </div>
      );
    }

    return this.props.children;
  }
}

export const Overview = () => {
  return (
    <Flex vertical gap={16}>
      <Flex gap={16}>
        <Flex flex={1}>
          <Card className="full-width">
            <CardWithErrorBoundary title="Online Status">
              <OnlineStatusCard />
            </CardWithErrorBoundary>
          </Card>
        </Flex>
        <Flex flex={1}>
          <Card className="full-width">
            <CardWithErrorBoundary title="Charger Activity">
              <ChargerActivityCard />
            </CardWithErrorBoundary>
          </Card>
        </Flex>
        <Flex flex={1}>
          <Card className="full-width">
            <CardWithErrorBoundary title="Plugin Success Rate">
              <PluginSuccessRateCard />
            </CardWithErrorBoundary>
          </Card>
        </Flex>
      </Flex>
      <Flex gap={16} align="start">
        <Flex flex={5}>
          <Card
            className="full-width locations-card-container"
            style={{ minHeight: 500 }}
          >
            <CardWithErrorBoundary title="Locations Map">
              <LocationsCard />
            </CardWithErrorBoundary>
          </Card>
        </Flex>
        <Flex flex={4}>
          <Card className="full-width">
            <CardWithErrorBoundary title="Active Transactions">
              <ActiveTransactionsCard />
            </CardWithErrorBoundary>
          </Card>
        </Flex>
        {/* <Flex flex={3}>
          <Card className="full-width">
            <FaultedChargersCard />
          </Card>
        </Flex> */}
      </Flex>
    </Flex>
  );
};

export const routes: React.FC = () => {
  return (
    <Routes>
      <Route index element={<Overview />} />
    </Routes>
  );
};
