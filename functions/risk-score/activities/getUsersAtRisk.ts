// getUsersAtRisk.ts - Activity: Query Cosmos for users at risk
import { AzureFunction, Context } from '@azure/functions';
import { logEvent } from '../shared/telemetry';

const activity: AzureFunction = async function (context: Context): Promise<any> {
  // TODO: Implement Cosmos query for users at risk (mock for now)
  await logEvent('getUsersAtRisk', { agentTool: 'risk-score', outcome: 'mock', latencyMs: 0 });
  return [{ userId: 'user1' }, { userId: 'user2' }];
};

export default activity;
