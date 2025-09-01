"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const httpTrigger = async function (context, req) {
    try {
        const body = (req?.body ?? {});
        const signals = (body.signals ?? {});
        const cravings = Number(signals.cravings ?? 0);
        const anomaly = Number(signals.anomalyScore ?? 0);
        const missed = Number(signals.missedCheckins ?? 0);
        // regra simples só para exemplo
        const riskScore = Math.min(100, cravings * 10 + anomaly * 50 + missed * 15);
        context.res = {
            status: 200,
            headers: { "Content-Type": "application/json" },
            body: { ok: true, riskScore }
        };
    }
    catch (err) {
        context.log.error("riskScore error", err);
        context.res = { status: 500, body: { ok: false, error: String(err?.message ?? err) } };
    }
};
exports.default = httpTrigger;
