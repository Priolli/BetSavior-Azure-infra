// invokeDailyCheckin.ts - Activity: Send daily check-in nudge (mock ACS)
import { AzureFunction, Context } from '@azure/functions';
import { logEvent } from '../shared/telemetry';

const activity: AzureFunction = async function (context: Context, input: any): Promise<any> {
  // TODO: Integrate with ACS (mock for now)
  await logEvent('invokeDailyCheckin', { agentTool: 'risk-score', outcome: 'mock', userId: input?.userId, latencyMs: 0 });
  return { sent: true };
};

export default activity;
