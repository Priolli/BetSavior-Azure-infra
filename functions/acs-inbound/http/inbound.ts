// inbound.ts - ACS webhook HTTP trigger (TypeScript)
// Validates signature, logs session to Cosmos, returns 200
import { AzureFunction, Context, HttpRequest } from '@azure/functions';
import { logEvent } from '../../risk-score/shared/telemetry';

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
  const start = Date.now();
  try {
    // TODO: Validate ACS webhook signature (mock)
    // TODO: Write session to Cosmos (mock)
    await logEvent('acsInbound', {
      agentTool: 'acs-inbound',
      outcome: 'success',
      latencyMs: Date.now() - start
    });
    context.res = { status: 200, body: { ok: true } };
  } catch (err) {
    await logEvent('acsInbound', {
      agentTool: 'acs-inbound',
      outcome: 'error',
      latencyMs: Date.now() - start,
      error: err instanceof Error ? err.message : String(err)
    });
    context.res = { status: 500, body: { error: 'Internal error' } };
  }
};

export default httpTrigger;
