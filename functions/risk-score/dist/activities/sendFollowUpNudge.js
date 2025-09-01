"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// se usa util local:
const telemetry_1 = require("../shared/telemetry"); // (sem .js, OK no CJS)
const activity = async function (context, input) {
    // TODO: Integrate with ACS (mock for now)
    await (0, telemetry_1.logEvent)('sendFollowUpNudge', { agentTool: 'risk-score', outcome: 'mock', userId: input?.userId, latencyMs: 0 });
    return { sent: true };
};
exports.default = activity;
