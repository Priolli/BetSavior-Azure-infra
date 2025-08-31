// missedCheckinOrchestrator.ts - Durable orchestrator for missed check-ins
import { AzureFunction, Context, DurableOrchestrationContext } from '@azure/functions';

const orchestrator: AzureFunction = function* (context: Context) {
  const df = context.df as DurableOrchestrationContext;
  const users = yield df.callActivity('getUsersAtRisk');
  for (const user of users) {
    yield df.callActivity('invokeDailyCheckin', user);
    const event = yield df.waitForExternalEvent('CheckinCompleted', 24 * 60 * 60 * 1000); // 24h timeout
    if (!event) {
      yield df.callActivity('sendFollowUpNudge', user);
    }
  }
  return { processed: users.length };
};

export default orchestrator;
