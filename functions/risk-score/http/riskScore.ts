import { AzureFunction, Context, HttpRequest } from "@azure/functions";

type Signals = {
  cravings?: number;
  anomalyScore?: number;
  missedCheckins?: number;
};

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
  try {
    const body = (req?.body ?? {}) as Record<string, any>;
    const signals: Signals = (body.signals ?? {}) as Signals;

    const cravings = Number(signals.cravings ?? 0);
    const anomaly = Number(signals.anomalyScore ?? 0);
    const missed  = Number(signals.missedCheckins ?? 0);

    // regra simples só para exemplo
    const riskScore = Math.min(100,
      cravings * 10 + anomaly * 50 + missed * 15
    );

    context.res = {
      status: 200,
      headers: { "Content-Type": "application/json" },
      body: { ok: true, riskScore }
    };
  } catch (err: any) {
    context.log.error("riskScore error", err);
    context.res = { status: 500, body: { ok: false, error: String(err?.message ?? err) } };
  }
};

export default httpTrigger;
