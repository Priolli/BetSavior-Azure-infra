"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appInsightsClient = void 0;
exports.logEvent = logEvent;
// shared/telemetry.ts - Application Insights telemetry helpers
const applicationinsights_1 = require("applicationinsights");
const appInsightsKey = process.env.APPINSIGHTS_INSTRUMENTATIONKEY;
exports.appInsightsClient = appInsightsKey ? new applicationinsights_1.TelemetryClient(appInsightsKey) : undefined;
async function logEvent(eventName, props) {
    if (exports.appInsightsClient) {
        exports.appInsightsClient.trackEvent({ name: eventName, properties: props });
        exports.appInsightsClient.flush();
    }
}
