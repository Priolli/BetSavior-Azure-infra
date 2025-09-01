// missedCheckinOrchestrator.ts - Durable orchestrator for missed check-ins
import { AzureFunction, Context } from "@azure/functions";
import * as df from "durable-functions";

const orchestrator: AzureFunction = df.orchestrator(function* (context: df.OrchestrationContext) {
  const users: any[] = yield context.df.callActivity("getUsersAtRisk");

  for (const u of users ?? []) {
    yield context.df.callActivity("invokeDailyCheckin", u);

    const event = yield context.df.waitForExternalEvent("CheckinCompleted", 24 * 60 * 60 * 1000);
    if (!event) {
      yield context.df.callActivity("sendFollowUpNudge", u);
    }
  }

  return { processed: users?.length ?? 0 };
});

export default orchestrator;
