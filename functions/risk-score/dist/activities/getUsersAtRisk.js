"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const telemetry_1 = require("../shared/telemetry");
const activity = async function (context) {
    // TODO: Implement Cosmos query for users at risk (mock for now)
    await (0, telemetry_1.logEvent)('getUsersAtRisk', { agentTool: 'risk-score', outcome: 'mock', latencyMs: 0 });
    return [{ userId: 'user1' }, { userId: 'user2' }];
};
exports.default = activity;
