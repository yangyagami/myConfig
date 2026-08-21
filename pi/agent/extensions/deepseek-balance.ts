/**
 * DeepSeek Balance Status Extension
 *
 * 在 pi 底部状态栏（footer）实时显示 DeepSeek 账户余额，默认每 60 秒刷新一次。
 *
 * API key 来源（按优先级，可多账号，自动去重）：
 *   1. pi 凭证文件 ~/.pi/agent/auth.json 中的 "deepseek" 条目（与 `/login deepseek` 复用同一份 key）
 *   2. 环境变量 DEEPSEEK_API_KEY（逗号分隔多个 key）
 *   3. 文件 ~/.pi/deepseek-keys（每行一个 key，# 开头为注释）
 *
 * 安装：把本文件路径加入 ~/.pi/agent/settings.json 的 "extensions" 数组：
 *   "extensions": ["~/.pi/agent/extensions/deepseek-balance.ts"]
 */

import type { ExtensionAPI, ExtensionHandler, SessionStartEvent, SessionShutdownEvent } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const STATUS_ID = "deepseek-balance";
const API_URL = "https://api.deepseek.com/user/balance";
const POLL_INTERVAL_MS = 60_000;
const FETCH_TIMEOUT_MS = 10_000;

const WARN_THRESHOLD = 20; // 余额低于此值显示黄色
const CRIT_THRESHOLD = 5; // 余额低于此值显示红色

interface BalanceInfo {
	currency: string;
	total_balance: string;
	granted_balance: string;
	topped_up_balance: string;
}

interface BalanceResponse {
	is_available: boolean;
	balance_infos: BalanceInfo[];
}

type BalanceLevel = "ok" | "warn" | "crit";

/** 收集所有可用的 DeepSeek API key（去重） */
function getApiKeys(): string[] {
	const keys = new Set<string>();

	// 1. pi 凭证文件（/login deepseek 写入）
	try {
		const authPath = join(homedir(), ".pi", "agent", "auth.json");
		if (existsSync(authPath)) {
			const auth = JSON.parse(readFileSync(authPath, "utf8")) as Record<
				string,
				{ type?: string; key?: string }
			>;
			const entry = auth["deepseek"];
			if (entry?.key) keys.add(entry.key.trim());
		}
	} catch {
		// 凭证文件不存在或解析失败时忽略
	}

	// 2. 环境变量（逗号分隔多个 key）
	for (const k of (process.env.DEEPSEEK_API_KEY ?? "").split(",")) {
		const t = k.trim();
		if (t) keys.add(t);
	}

	// 3. 用户级 key 文件（每行一个）
	try {
		const file = join(homedir(), ".pi", "deepseek-keys");
		if (existsSync(file)) {
			for (const line of readFileSync(file, "utf8").split(/\r?\n/)) {
				const t = line.trim();
				if (t && !t.startsWith("#")) keys.add(t);
			}
		}
	} catch {
		// 忽略
	}

	return [...keys];
}

async function fetchBalance(key: string): Promise<BalanceResponse> {
	const res = await fetch(API_URL, {
		headers: { Authorization: `Bearer ${key}` },
		signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
	});
	if (!res.ok) throw new Error(`HTTP ${res.status}`);
	return (await res.json()) as BalanceResponse;
}

function formatAmount(raw: string, currency: string): string {
	const n = Number(raw);
	const symbol = currency === "CNY" ? "¥" : currency === "USD" ? "$" : `${currency} `;
	if (!Number.isFinite(n)) return `${symbol}--`;
	return symbol + (Number.isInteger(n) ? String(n) : n.toFixed(2));
}

function levelFor(total: number): BalanceLevel {
	if (total < CRIT_THRESHOLD) return "crit";
	if (total < WARN_THRESHOLD) return "warn";
	return "ok";
}

// 余额严重程度优先级：crit > warn > ok
const LEVEL_PRIORITY: Record<BalanceLevel, number> = { ok: 0, warn: 1, crit: 2 };
// 各严重程度对应的状态栏颜色
const COLOR_BY_LEVEL: Record<BalanceLevel, "dim" | "error" | "warning"> = {
	ok: "dim",
	warn: "warning",
	crit: "error",
};

type SessionCtx = Parameters<ExtensionHandler<SessionStartEvent>>[1];

export default function (pi: ExtensionAPI) {
	// 当前有效会话 ctx：session 替换（/new、/fork、/resume、reload）后会指向新 ctx，
	// 旧的会被 pi 标记为 stale，禁止再访问其 ui。
	let latestCtx: SessionCtx | undefined;
	let timer: ReturnType<typeof setInterval> | undefined;

	pi.on("session_shutdown", ((_event: SessionShutdownEvent) => {
		// 扩展运行时即将因 quit/reload/new/resume/fork 被拆除，清理轮询
		latestCtx = undefined;
		if (timer) {
			clearInterval(timer);
			timer = undefined;
		}
	}) satisfies ExtensionHandler<SessionShutdownEvent>);

	pi.on("session_start", (async (event: SessionStartEvent, ctx: SessionCtx) => {
		// 每次会话启动（startup / reload / new / resume / fork）都拿到全新有效 ctx，
		// 必须重新绑定并重建 timer，绝不能复用被替换会话的 ctx。
		latestCtx = ctx;
		if (timer) {
			clearInterval(timer);
			timer = undefined;
		}

		const theme = ctx.ui.theme;
		const keys = getApiKeys();

		if (keys.length === 0) {
			ctx.ui.setStatus(
				STATUS_ID,
				theme.fg("warning", "DS 未配置 key（/login deepseek 或 DEEPSEEK_API_KEY）"),
			);
			return;
		}

		const refresh = async () => {
			const myCtx = latestCtx;
			if (!myCtx) return;
			try {
				const results = await Promise.allSettled(keys.map((key) => fetchBalance(key)));

				// 会话已切换/替换：丢弃本轮结果，避免触碰 stale ctx
				if (latestCtx !== myCtx) return;

				const perKey: string[] = [];
				let worst: BalanceLevel = "ok";
				let anyOk = false;

				for (const r of results) {
					if (r.status === "rejected") {
						perKey.push("--");
						continue;
					}
					const res = r.value;
					if (!res.is_available) {
						perKey.push("不可用");
						worst = "crit";
						continue;
					}
					if (res.balance_infos.length === 0) {
						perKey.push("--");
						continue;
					}
					anyOk = true;
					const amounts = res.balance_infos.map((info) => {
						const total = Number(info.total_balance);
						if (Number.isFinite(total)) {
							const lv = levelFor(total);
							if (LEVEL_PRIORITY[lv] > LEVEL_PRIORITY[worst]) worst = lv;
						}
						return formatAmount(info.total_balance, info.currency);
					});
					perKey.push(amounts.join("/"));
				}

				if (latestCtx !== myCtx) return;

				const text = "DS " + perKey.join(" | ");
				// 全部拉取失败时置灰等待重试，否则按最差余额等级着色
				const color: "dim" | "error" | "warning" = anyOk ? COLOR_BY_LEVEL[worst] : "dim";
				myCtx.ui.setStatus(STATUS_ID, theme.fg(color, text));
			} catch {
				// 兜底：任何意外错误都不应导致进程崩溃，置灰显示等待下轮重试
				if (latestCtx === myCtx) {
					myCtx.ui.setStatus(STATUS_ID, theme.fg("dim", "DS --"));
				}
			}
		};

		ctx.ui.setStatus(STATUS_ID, theme.fg("dim", "DS …"));
		void refresh();
		timer = setInterval(() => void refresh(), POLL_INTERVAL_MS);
	}) satisfies ExtensionHandler<SessionStartEvent>);
}
