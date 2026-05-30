/**
 * opencode-quota-tracker — Model Usage & Quota Tracker
 *
 * Tracks token usage, costs, and quota across all sessions.
 * Persists data to a JSON file for querying via command or tool.
 *
 * Plugin type: Server-side Plugin (auto-discovered from .opencode/plugin/)
 * Events:      event hook captures assistant message token/cost data
 * Persistence: ~/.local/share/opencode/quota-tracker.json
 */

import type { Plugin } from "@opencode-ai/plugin";

/* ------------------------------------------------------------------ */
/*  Types                                                             */
/* ------------------------------------------------------------------ */

interface TokenCounts {
  input: number;
  output: number;
  reasoning: number;
  cacheRead: number;
  cacheWrite: number;
}

interface SessionRecord {
  title: string;
  tokens: TokenCounts;
  cost: number;
  modelID: string;
  providerID: string;
  time: string;
  messages: number;
}

interface ModelTotals {
  input: number;
  output: number;
  reasoning: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  sessions: number;
  messages: number;
}

interface QuotaData {
  version: number;
  sessions: Record<string, SessionRecord>;
  totals: Record<string, ModelTotals>;
  lastUpdated: string;
}

/* ------------------------------------------------------------------ */
/*  Plugin                                                             */
/* ------------------------------------------------------------------ */

const QuotaTrackerPlugin: Plugin = async () => {
  /* ---- state ---- */
  let data: QuotaData;
  let dirty = false;

  /* ---- persistence ---- */
  const { readFile, writeFile } = await import("node:fs/promises");
  const { join } = await import("node:path");
  const { homedir } = await import("node:os");

  const dataDir = join(homedir(), ".local", "share", "opencode");
  const dataFile = join(dataDir, "quota-tracker.json");

  async function load(): Promise<void> {
    try {
      const raw = await readFile(dataFile, "utf-8");
      data = JSON.parse(raw) as QuotaData;
      if (data.version === 1) return;
    } catch { /* corrupt or missing */ }
    data = {
      version: 1,
      sessions: {},
      totals: {},
      lastUpdated: new Date().toISOString(),
    };
  }

  async function flush(): Promise<void> {
    if (!dirty) return;
    dirty = false;
    data.lastUpdated = new Date().toISOString();
    try {
      // ensure data dir exists
      const { mkdir } = await import("node:fs/promises");
      await mkdir(dataDir, { recursive: true });
      await writeFile(dataFile, JSON.stringify(data, null, 2), "utf-8");
    } catch (err) {
      console.error("[quota-tracker] failed to write:", err);
    }
  }

  await load();

  /* flush every 5s when dirty */
  let flushTimer: ReturnType<typeof setInterval> | undefined;
  if (typeof setInterval !== "undefined") {
    flushTimer = setInterval(flush, 5000);
  }

  /* ---- helpers ---- */

  const modelKey = (p: string, m: string): string => `${p}/${m}`;

  const recordMessage = (msg: {
    sessionID: string;
    modelID: string;
    providerID: string;
    tokens: {
      input: number;
      output: number;
      reasoning: number;
      cache: { read: number; write: number };
    };
    cost: number;
  }): void => {
    const key = modelKey(msg.providerID, msg.modelID);
    const t = msg.tokens;

    /* per-session */
    let session = data.sessions[msg.sessionID];
    if (!session) {
      session = {
        title: "",
        tokens: { input: 0, output: 0, reasoning: 0, cacheRead: 0, cacheWrite: 0 },
        cost: 0,
        modelID: msg.modelID,
        providerID: msg.providerID,
        time: new Date().toISOString(),
        messages: 0,
      };
      data.sessions[msg.sessionID] = session;
    }
    session.tokens.input += t.input;
    session.tokens.output += t.output;
    session.tokens.reasoning += t.reasoning;
    session.tokens.cacheRead += t.cache.read;
    session.tokens.cacheWrite += t.cache.write;
    session.cost += msg.cost;
    session.messages += 1;
    session.time = new Date().toISOString();
    session.modelID = msg.modelID;
    session.providerID = msg.providerID;

    /* per-model totals */
    let m = data.totals[key];
    if (!m) {
      m = {
        input: 0, output: 0, reasoning: 0,
        cacheRead: 0, cacheWrite: 0,
        cost: 0, sessions: 0, messages: 0,
      };
      data.totals[key] = m;
    }
    m.input += t.input;
    m.output += t.output;
    m.reasoning += t.reasoning;
    m.cacheRead += t.cache.read;
    m.cacheWrite += t.cache.write;
    m.cost += msg.cost;
    m.messages += 1;
    m.sessions = Object.values(data.sessions).filter(
      (s) => modelKey(s.providerID, s.modelID) === key,
    ).length;

    dirty = true;
  };

  return {
    /* ---- event tracking ---- */
    event: async ({ event }) => {
      if (event.type !== "message.updated") return;
      const msg = event.properties.info;
      if (msg.role !== "assistant") return;
      if (!msg.tokens) return; // still streaming

      recordMessage({
        sessionID: msg.sessionID,
        modelID: msg.modelID,
        providerID: msg.providerID,
        tokens: msg.tokens,
        cost: msg.cost ?? 0,
      });
    },

    /* ---- cleanup ---- */
    dispose: async () => {
      if (flushTimer) clearInterval(flushTimer);
      await flush();
    },
  };
};

export default QuotaTrackerPlugin;
