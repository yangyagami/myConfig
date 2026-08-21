/**
 * pi-confirm - Tool Confirmation Extension
 *
 * Two-mode tool confirmation for pi coding agent.
 *
 * Modes:
 *   plan  - System prompt instructs LLM to only discuss/explore.
 *           Blocks only write/edit tools. Bash is fully available
 *           but the system prompt strongly guides read-only behavior.
 *   work  - Confirm only on dangerous patterns (rm -rf, sudo, etc.)
 *           with an overlay dialog (left/right to choose Yes/No).
 *
 * Install: place in ~/.pi/agent/extensions/confirm.ts
 * Configure: ~/.pi/agent/settings.json or .pi/settings.json
 * Manage: /confirm command
 * Toggle: Alt+C
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { matchesKey, Key, type Component } from "@earendil-works/pi-tui";

// ─── Types ─────────────────────────────────────────────────────────

type ConfirmMode = "plan" | "work";

interface ConfirmSettings {
	mode: ConfirmMode;
	nonInteractiveBlock: boolean;
	dangerousBashPatterns: string[];
	protectedPaths: string[];
}

interface ConfirmState {
	whitelistedCommands: string[];
	whitelistedPaths: string[];
	allowedTools: string[];
}

// ─── Defaults ──────────────────────────────────────────────────────

const DEFAULT_SETTINGS: ConfirmSettings = {
	mode: "work",
	nonInteractiveBlock: true,
	dangerousBashPatterns: [
		"\\brm\\s+(-rf?|--recursive)\\s+",
		"\\bsudo\\s+",
		"\\b(chmod|chown)\\s+.*777",
		"\\bdd\\s+.*of=",
		"\\bmkfs\\.",
		"\\b:(){ :|:& };:",
		"\\bcurl\\s+.*\\|?\\s*(ba)?sh\\b",
		"\\bwget\\s+.*-O\\s*-\\s*\\|?\\s*(ba)?sh\\b",
		"\\bgit\\s+push\\s+--force\\b",
		"\\bDROP\\s+(TABLE|DATABASE)\\b",
	],
	protectedPaths: [
		".env",
		".env.*",
		"node_modules/",
		".git/",
		"*.pem",
		"*.key",
	],
};

const DEFAULT_STATE: ConfirmState = {
	whitelistedCommands: [],
	whitelistedPaths: [],
	allowedTools: [],
};

// Plan mode only blocks write/edit; bash is fully allowed.
// The system prompt (see before_agent_start) is the primary constraint.

// ─── Yes/No Overlay Dialog ─────────────────────────────────────────

/**
 * Renders a modal overlay dialog with a Yes/No toggle.
 * Left/Right arrow keys (or h/l) switch between Yes and No.
 * Enter/Space confirms, Escape cancels (same as selecting No).
 */
class YesNoDialog implements Component {
	private selected: boolean = false; // false = No, true = Yes
	private cachedWidth?: number;
	private cachedLines?: string[];

	public onDone?: (confirmed: boolean) => void;

	constructor(
		private title: string,
		private details: string[],
	) {}

	handleInput(data: string): void {
		if (matchesKey(data, Key.left) || matchesKey(data, Key.right) || data === "h" || data === "l") {
			this.selected = !this.selected;
			this.invalidate();
		} else if (matchesKey(data, Key.enter) || matchesKey(data, Key.space)) {
			this.onDone?.(this.selected);
		} else if (matchesKey(data, Key.escape)) {
			this.onDone?.(false);
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) {
			return this.cachedLines;
		}

		const maxContentWidth = Math.min(width - 4, 70);
		const lines: string[] = [];

		// Wrap details into a box with padding
		const titleWrapped = this.wrapText(`╭─ ${this.title} `.padEnd(maxContentWidth - 1, "─") + "╮", maxContentWidth);
		lines.push(...titleWrapped);

		// Empty line
		lines.push("│" + " ".repeat(maxContentWidth - 2) + "│");

		// Detail lines
		for (const detail of this.details) {
			const truncated = detail.length > maxContentWidth - 4
				? detail.slice(0, maxContentWidth - 7) + "..."
				: detail;
			lines.push("│ " + truncated.padEnd(maxContentWidth - 3) + "│");
		}

		// Empty line before buttons
		lines.push("│" + " ".repeat(maxContentWidth - 2) + "│");

		// Yes / No buttons
		const yesBtn = this.selected ? " [ YES ] " : "   yes   ";
		const noBtn = this.selected ? "   no    " : " [ NO ]  ";
		const sep = "    ";
		const btnLine = yesBtn + sep + noBtn;
		const padLeft = Math.max(0, Math.floor((maxContentWidth - 2 - btnLine.length) / 2));
		lines.push("│ " + " ".repeat(padLeft) + btnLine + " ".repeat(maxContentWidth - 2 - padLeft - btnLine.length) + " │");

		// Help line
		const helpText = "← → to toggle  •  Enter to confirm  •  Esc to cancel";
		const helpPad = Math.max(0, Math.floor((maxContentWidth - 2 - helpText.length) / 2));
		lines.push("│ " + " ".repeat(helpPad) + helpText + " ".repeat(maxContentWidth - 2 - helpPad - helpText.length) + " │");

		// Bottom border
		lines.push("╰" + "─".repeat(maxContentWidth - 2) + "╯");

		this.cachedLines = lines;
		this.cachedWidth = width;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}

	private wrapText(text: string, maxWidth: number): string[] {
		if (text.length <= maxWidth) return [text];
		return [text.slice(0, maxWidth)];
	}
}

/**
 * Show the Yes/No overlay dialog. Returns true if user confirmed (Yes), false otherwise.
 */
async function showConfirmDialog(
	ctx: ExtensionContext,
	title: string,
	details: string[],
): Promise<boolean> {
	const result = await ctx.ui.custom<boolean>((_tui, _theme, _keybindings, done) => {
		const dialog = new YesNoDialog(title, details);
		dialog.onDone = (confirmed) => done(confirmed);
		return {
			render: (w: number) => dialog.render(w),
			invalidate: () => dialog.invalidate(),
			handleInput: (data: string) => dialog.handleInput(data),
		};
	}, {
		overlay: true,
		overlayOptions: {
			anchor: "center",
			width: 60,
			minWidth: 40,
		},
	});

	return result ?? false;
}

// ─── Main extension ───────────────────────────────────────────────

export default function confirmExtension(pi: ExtensionAPI) {
	// ── State ─────────────────────────────────────────────────────
	let settings: ConfirmSettings = { ...DEFAULT_SETTINGS };
	let state: ConfirmState = { ...DEFAULT_STATE };

	// Stats tracking
	let statsTotalBlocked = 0;
	let statsTotalAllowed = 0;

	// Timer handle for widget auto-clear
	let widgetClearTimer: ReturnType<typeof setTimeout> | undefined;

	// ── Helpers ───────────────────────────────────────────────────

	function loadSettings(): ConfirmSettings {
		const merged: ConfirmSettings = { ...DEFAULT_SETTINGS };

		try {
			const fs = require("node:fs");
			const path = require("node:path");
			const os = require("node:os");

			const globalPath = path.join(os.homedir(), ".pi", "agent", "settings.json");
			const projectPath = path.join(process.cwd(), ".pi", "settings.json");

			for (const filePath of [globalPath, projectPath]) {
				if (fs.existsSync(filePath)) {
					const raw = JSON.parse(fs.readFileSync(filePath, "utf-8"));
					const confirm = raw.confirm as Partial<ConfirmSettings>;
					if (confirm) {
						if (confirm.mode) merged.mode = confirm.mode;
						if (confirm.nonInteractiveBlock !== undefined) merged.nonInteractiveBlock = confirm.nonInteractiveBlock;
						if (confirm.dangerousBashPatterns) merged.dangerousBashPatterns = confirm.dangerousBashPatterns;
						if (confirm.protectedPaths) merged.protectedPaths = confirm.protectedPaths;
					}
				}
			}
		} catch {
			// Use defaults
		}

		return merged;
	}

	function compilePatterns(patterns: string[]): RegExp[] {
		return patterns.map((p) => new RegExp(p, "i"));
	}

	function isPathProtected(filePath: string): boolean {
		return settings.protectedPaths.some((pattern) => {
			const globPattern = pattern
				.replace(/\./g, "\\.")
				.replace(/\*/g, ".*");
			const regex = new RegExp(globPattern, "i");
			return regex.test(filePath);
		});
	}

	function isBashDangerous(command: string): boolean {
		const patterns = compilePatterns(settings.dangerousBashPatterns);
		return patterns.some((p) => p.test(command));
	}

	function getModeColor(mode: ConfirmMode): string {
		return mode === "work" ? "warning" : "muted";
	}

	function getModeLabel(mode: ConfirmMode): string {
		return mode === "work" ? "Work" : "Plan";
	}

	function updateStatus(ctx: ExtensionContext, mode: ConfirmMode) {
		const colorName = getModeColor(mode);
		const label = getModeLabel(mode);
		ctx.ui.setStatus(
			"confirm",
			ctx.ui.theme.fg(colorName, `● ${label}`),
		);
	}

	function showModeToast(ctx: ExtensionContext, mode: ConfirmMode) {
		const colorName = getModeColor(mode);
		const label = getModeLabel(mode);

		if (widgetClearTimer) clearTimeout(widgetClearTimer);
		ctx.ui.setWidget("confirm-mode", [
			ctx.ui.theme.fg(colorName, `╔═══ 🛡 confirm: ${label} ═══╗`),
		]);
		widgetClearTimer = setTimeout(() => {
			ctx.ui.setWidget("confirm-mode", undefined);
		}, 3000);
	}

	function persistState() {
		pi.appendEntry<ConfirmState>("confirm-state", { ...state });
	}

	function restoreState(ctx: ExtensionContext) {
		const branchEntries = ctx.sessionManager.getBranch();
		for (const entry of branchEntries) {
			if (entry.type === "custom" && entry.customType === "confirm-state") {
				const data = entry.data as ConfirmState | undefined;
				if (data) {
					state = {
						whitelistedCommands: data.whitelistedCommands ?? [],
						whitelistedPaths: data.whitelistedPaths ?? [],
						allowedTools: data.allowedTools ?? [],
					};
				}
			}
		}
	}

	// ── Before agent start: inject plan-mode system prompt ──────

	pi.on("before_agent_start", async (event, ctx) => {
		if (settings.mode !== "plan") return;

		return {
			systemPrompt:
				event.systemPrompt +
				"\n\n" +
				"## ⛔ PLAN MODE — READ-ONLY EXPLORATION\n" +
				"You are in PLAN MODE. Your role is to **explore, analyze, and propose** — never to modify.\n\n" +
				"### Hard Restrictions (system-enforced)\n" +
				"- `write` and `edit` tools are **BLOCKED** by the system. You cannot create or modify files.\n" +
				"- Attempting write/edit will result in an error. Do not try.\n\n" +
				"### Bash — Fully Available, But You Must Act as a Read-Only Explorer\n" +
				"- Bash is **fully available** for reading, searching, and inspecting the codebase.\n" +
				"- **However**, as a plan-mode explorer you MUST NOT use bash for:\n" +
				"  - Deleting, moving, or creating files (rm, mv, touch, mkdir, etc.)\n" +
				"  - Installing packages (npm install, pip install, apt install, brew install, etc.)\n" +
				"  - Modifying permissions (chmod, chown, sudo)\n" +
				"  - Git mutations (commit, push, merge, rebase, stash, branch -d, tag, etc.)\n" +
				"  - Editing files in-place (sed -i, tee, `cmd > file`, `cmd >> file`)\n" +
				"  - Running editors (vim, nano, code, etc.)\n" +
				"  - System mutations (systemctl start/stop, kill, reboot, shutdown, etc.)\n" +
				"- Use bash freely for: ls, cat, grep, rg, find, fd, git status/log/diff/show, pwd, echo, wc, " +
				"head, tail, file, stat, jq, curl (GET), npm/yarn list/audit, and similar read-only operations.\n\n" +
				"### What You SHOULD Do\n" +
				"1. **Explore** — use read, bash, grep, find to understand the codebase\n" +
				"2. **Ask** — use questionnaire for clarifying questions when needed\n" +
				"3. **Plan** — create a detailed numbered plan under a **Plan:** header\n" +
				"4. **Recommend** — tell the user to switch to work mode (`/confirm mode work`) when ready to execute\n\n" +
				"**Golden rule:** You are the scout, not the builder. Understand first, act later.",
		};
	});

	// ── Tool call interceptor ─────────────────────────────────────

	pi.on("tool_call", async (event, ctx) => {
		if (state.allowedTools.includes(event.toolName)) return;

		// ── Plan mode ──────────────────────────────────────────
		if (settings.mode === "plan") {
			// Only block write / edit. Bash and all other tools pass through.
			if (event.toolName === "write" || event.toolName === "edit") {
				statsTotalBlocked++;
				return {
					block: true,
					reason:
						"[pi-confirm] Plan mode: file modification is blocked. " +
						"You should make a plan instead of edit code!!!!",
				};
			}

			// All other tools pass through (bash, read, etc.)
			return;
		}

		// ── Work mode: confirm on dangerous patterns ──────────
		if (settings.mode === "work") {
			if (!isWorkModeConfirmNeeded(event.toolName, event.input)) return;

			if (!ctx.hasUI) {
				if (settings.nonInteractiveBlock) {
					statsTotalBlocked++;
					return {
						block: true,
						reason: `[pi-confirm] Blocked in non-interactive mode (mode: work)`,
					};
				}
				return;
			}

			const risk = getToolRisk(event.input);

			let previewLines: string[] = [];
			if (event.toolName === "bash") {
				previewLines.push(`$ ${(event.input.command as string) ?? ""}`);
			} else if (event.toolName === "write" || event.toolName === "edit") {
				previewLines.push(`File: ${(event.input.path as string) ?? ""}`);
				if (event.toolName === "edit" && event.input.oldText) {
					const oldText = (event.input.oldText as string).slice(0, 200);
					previewLines.push(`Replace: "${oldText}${oldText.length >= 200 ? "..." : ""}"`);
				}
			} else {
				previewLines.push(JSON.stringify(event.input, null, 2).slice(0, 300));
			}

			const riskIndicator = "●".repeat(risk.level) + "○".repeat(5 - risk.level);
			const title = risk.level >= 4 ? "🛡 Critical Action" : "⚠ High-Risk Action";
			const detailLines = [
				`Tool: ${event.toolName}`,
				`Risk: ${riskIndicator} ${risk.label}`,
				"",
				...previewLines,
			];

			const confirmed = await showConfirmDialog(ctx, title, detailLines);

			if (!confirmed) {
				statsTotalBlocked++;
				return { block: true, reason: "[pi-confirm] Denied by user" };
			}

			statsTotalAllowed++;
		}
	});

	function isWorkModeConfirmNeeded(toolName: string, input: Record<string, unknown>): boolean {
		if (state.allowedTools.includes(toolName)) return false;

		if (toolName === "bash") {
			const cmd = (input.command as string) ?? "";
			if (state.whitelistedCommands.some((w) => cmd.includes(w))) return false;
			return isBashDangerous(cmd);
		}
		if (toolName === "write" || toolName === "edit") {
			const filePath = (input.path as string) ?? "";
			if (state.whitelistedPaths.some((w) => filePath.includes(w))) return false;
			return isPathProtected(filePath);
		}
		return false;
	}

	function getToolRisk(input: Record<string, unknown>): { level: number; label: string } {
		const cmd = (input.command as string) ?? "";
		const filePath = (input.path as string) ?? "";

		if (isBashDangerous(cmd) || isPathProtected(filePath)) {
			return { level: 4, label: "Critical" };
		}
		return { level: 3, label: "High" };
	}

	// ── Commands ──────────────────────────────────────────────────

	pi.registerCommand("confirm", {
		description: "Manage tool confirmation settings",
		handler: async (args, ctx) => {
			const trimmed = (args ?? "").trim();

			if (!trimmed) {
				const lines = [
					`╔═══════════════════════════════════╗`,
					`║  pi-confirm Status                ║`,
					`╠═══════════════════════════════════╣`,
					`║  Mode:      ${getModeLabel(settings.mode).padEnd(28)}║`,
					`║  Blocked:   ${String(statsTotalBlocked).padEnd(28)}║`,
					`║  Allowed:   ${String(statsTotalAllowed).padEnd(28)}║`,
					`╚═══════════════════════════════════╝`,
				];
				ctx.ui.notify(lines.join("\n"), "info");
				return;
			}

			const parts = trimmed.split(/\s+/);
			const subcommand = parts[0]!;

			switch (subcommand) {
				case "mode": {
					const newMode = parts[1] as ConfirmMode | undefined;
					if (!newMode || !["plan", "work"].includes(newMode)) {
						ctx.ui.notify("Usage: /confirm mode <plan|work>", "warning");
						return;
					}
					settings.mode = newMode;
					updateStatus(ctx, newMode);
					showModeToast(ctx, newMode);
					return;
				}

				case "stats": {
					const lines = [
						`╔═══════════════════════════════════╗`,
						`║  pi-confirm Statistics            ║`,
						`╠═══════════════════════════════════╣`,
						`║  Blocked:   ${String(statsTotalBlocked).padEnd(28)}║`,
						`║  Allowed:   ${String(statsTotalAllowed).padEnd(28)}║`,
						`║  Total:     ${String(statsTotalBlocked + statsTotalAllowed).padEnd(28)}║`,
						`╚═══════════════════════════════════╝`,
					];
					ctx.ui.notify(lines.join("\n"), "info");
					return;
				}

				case "reset": {
					state = { ...DEFAULT_STATE };
					statsTotalBlocked = 0;
					statsTotalAllowed = 0;
					settings = loadSettings();
					persistState();
					ctx.ui.notify("State reset to defaults", "info");
					return;
				}

				default: {
					ctx.ui.notify(
						`Unknown subcommand: ${subcommand}. Use: mode, stats, reset`,
						"warning",
					);
				}
			}
		},
	});

	// ── Session lifecycle ─────────────────────────────────────────

	settings = loadSettings();

	pi.on("session_start", async (_event, ctx) => {
		settings = loadSettings();
		restoreState(ctx);

		updateStatus(ctx, settings.mode);

		ctx.ui.notify(
			`🛡 confirm loaded (${getModeLabel(settings.mode)}). /confirm or Alt+C`,
			"info",
		);
	});

	pi.on("session_tree", async (_event, ctx) => {
		restoreState(ctx);
	});

	// ── Keyboard shortcut: toggle ────────────────────────────────
	// Alt+C — cycles between plan ↔ work

	pi.registerShortcut("alt+c", {
		description: "Toggle confirmation mode (plan ↔ work)",
		handler: async (ctx) => {
			const modes: ConfirmMode[] = ["plan", "work"];
			const currentIndex = modes.indexOf(settings.mode);
			const nextMode = modes[(currentIndex + 1) % modes.length]!;
			settings.mode = nextMode;

			updateStatus(ctx, nextMode);
			showModeToast(ctx, nextMode);
		},
	});
}
