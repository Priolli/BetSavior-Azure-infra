// riskScore.ts - HTTP trigger for risk scoring (TypeScript)
// Calculates riskScore based on input signals, logs to App Insights
import { AzureFunction, Context, HttpRequest } from '@azure/functions';
import { appInsightsClient, logEvent } from '../shared/telemetry';

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
  const start = Date.now();
  try {
    const { signals } = req.body || {};
    if (!signals || typeof signals !== 'object') {
      context.res = { status: 400, body: { error: 'Missing or invalid signals' } };
      return;
    }
    // Baseline risk formula: weighted sum, normalized [0,1]
    const cravings = Number(signals.cravings) || 0;
    const anomalyScore = Number(signals.anomalyScore) || 0;
    const missedCheckins = Number(signals.missedCheckins) || 0;
    let riskScore = 0.5 * (cravings / 10) + 0.3 * anomalyScore + 0.2 * Math.min(missedCheckins, 5) / 5;
    riskScore = Math.max(0, Math.min(1, riskScore));
    // Log custom event
    await logEvent('riskScore', {
      userId: req.headers['x-user-id'] || 'anon',
      agentTool: 'risk-score',
      latencyMs: Date.now() - start,
      outcome: 'success',
      riskScore
    });
    context.res = { status: 200, body: { riskScore } };
  } catch (err) {
    await logEvent('riskScore', {
      agentTool: 'risk-score',
      latencyMs: Date.now() - start,
      outcome: 'error',
      error: err.message
    });
    context.res = { status: 500, body: { error: 'Internal error' } };
  }
};

export default httpTrigger;
