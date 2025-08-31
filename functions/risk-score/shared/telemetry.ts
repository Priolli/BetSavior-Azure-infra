// shared/telemetry.ts - Application Insights telemetry helpers
import { TelemetryClient } from 'applicationinsights';

const appInsightsKey = process.env.APPINSIGHTS_INSTRUMENTATIONKEY;
export const appInsightsClient = appInsightsKey ? new TelemetryClient(appInsightsKey) : undefined;

export async function logEvent(eventName: string, props: Record<string, any>) {
  if (appInsightsClient) {
    appInsightsClient.trackEvent({ name: eventName, properties: props });
    appInsightsClient.flush();
  }
}
