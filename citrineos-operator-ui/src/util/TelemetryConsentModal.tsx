// SPDX-FileCopyrightText: 2025 Contributors to the CitrineOS Project
//
// SPDX-License-Identifier: Apache-2.0

import React from 'react';
import { Modal, Button } from 'antd';
import { BaseRestClient } from './BaseRestClient';
import { SystemConfig } from '@citrineos/base';

let systemConfig: SystemConfig | null = null;
const client = new BaseRestClient(null);

interface TelemetryConsentModalProps {
  /** Whether the modal is visible */
  visible: boolean;
  /** Handle user decision; receives `true` if user accepts, `false` if user rejects */
  onDecision: (agreed: boolean) => void;
}

export async function checkTelemetryConsent(): Promise<boolean | undefined> {
  // First check localStorage for user's previous choice
  const localConsent = localStorage.getItem('citrineos-telemetry-consent');
  if (localConsent !== null) {
    return localConsent === 'true';
  }

  // Fallback to backend API (if available)
  try {
    const systemConfigRaw = await client.getRaw(`/ocpprouter/systemConfig`);
    systemConfig = systemConfigRaw.data as SystemConfig;
    const telemetryConsent = systemConfig.userPreferences.telemetryConsent;
    if (typeof telemetryConsent === 'boolean') {
      // Save to localStorage for future use
      localStorage.setItem('citrineos-telemetry-consent', telemetryConsent.toString());
      return telemetryConsent;
    }
  } catch (error) {
    console.error('error checking system config', error);
  }
  return undefined;
}

export async function saveTelemetryConsent(
  telemetryConsent: boolean,
): Promise<void> {
  // Always save to localStorage for persistence
  localStorage.setItem('citrineos-telemetry-consent', telemetryConsent.toString());
  
  // Try to save to backend (if available)
  if (systemConfig === null) {
    // If systemConfig is not available, we still save to localStorage
    console.log('System config not initialized, saving to localStorage only');
    return;
  }
  
  systemConfig.userPreferences.telemetryConsent = telemetryConsent;
  try {
    await client.putRaw(`/ocpprouter/systemConfig`, systemConfig);
  } catch (error) {
    console.error('Error saving telemetry consent to backend, but saved to localStorage', error);
  }
}

/**
 * TelemetryConsentModal
 *
 * Displays a blocking modal to request consent for telemetry.
 */
export const TelemetryConsentModal: React.FC<TelemetryConsentModalProps> = ({
  visible,
  onDecision,
}) => {
  return (
    <Modal
      open={visible}
      title="Anonymous Metrics Consent"
      closable={false}
      maskClosable={false}
      footer={[
        <Button key="reject" onClick={() => onDecision(false)}>
          Reject
        </Button>,
        <Button key="accept" type="primary" onClick={() => onDecision(true)}>
          Accept
        </Button>,
      ]}
    >
      <p>
        CitrineOS collects anonymous usage metrics to help us improve the
        product. Would you like to send these metrics?
      </p>
    </Modal>
  );
};
