/**
 * pi-agent-art.ts
 *
 * Startup header art: "Pi AGENT" in the ANSI Shadow font (same style as the
 * pi-splash startup animation logo), rendered as a static rainbow — each
 * character gets its own hue, matching the splash screen's gradient sweep
 * (hue = 0.55 + i*0.08).
 *
 * Static on purpose: an animated header keeps re-rendering the TUI, which
 * fights with scrollback. Restore the built-in header anytime with:
 * /builtin-header
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// ── ANSI Shadow glyphs (7 rows each, from the figlet "ANSI Shadow" font) ──
const P = ["██████╗ ", "██╔══██╗", "██████╔╝", "██╔═══╝ ", "██║     ", "╚═╝     ", "        "];
const I = ["██╗", "██║", "██║", "██║", "██║", "╚═╝", "   "];
const A = [" █████╗ ", "██╔══██╗", "███████║", "██╔══██║", "██║  ██║", "╚═╝  ╚═╝", "        "];
const G = [" ██████╗ ", "██╔════╝ ", "██║  ███╗", "██║   ██║", "╚██████╔╝", " ╚═════╝ ", "         "];
const E = ["███████╗", "██╔════╝", "█████╗  ", "██╔══╝  ", "███████╗", "╚══════╝", "        "];
const N = ["███╗   ██╗", "████╗  ██║", "██╔██╗ ██║", "██║╚██╗██║", "██║ ╚████║", "╚═╝  ╚═══╝", "          "];
const T = ["████████╗", "╚══██╔══╝", "   ██║   ", "   ██║   ", "   ██║   ", "   ╚═╝   ", "         "];

const GLYPHS: Record<string, string[]> = { P, i: I, A, G, E, N, T };
const WORD = "Pi AGENT";
const LETTER_GAP = 1; // columns between letters
const WORD_GAP = 5; // columns between "Pi" and "AGENT"
const ROWS = 7;

const SUBTITLE = "coding agent harness";

// ── HSL → RGB (same as pi-splash) ─────────────────────────────
function hslToRgb(h: number, s: number, l: number): [number, number, number] {
  if (s === 0) return [Math.round(l * 255), Math.round(l * 255), Math.round(l * 255)];
  const hue2rgb = (p: number, q: number, t: number) => {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  };
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  const p = 2 * l - q;
  return [
    Math.round(hue2rgb(p, q, h + 1 / 3) * 255),
    Math.round(hue2rgb(p, q, h) * 255),
    Math.round(hue2rgb(p, q, h - 1 / 3) * 255),
  ];
}

function rgbFg(r: number, g: number, b: number): string {
  return `\x1b[38;2;${r};${g};${b}m`;
}
const RESET = "\x1b[0m";

// ── Build the art (static frame) ─────────────────────────────
function renderArt(width: number): string[] {
  const rows: string[] = new Array(ROWS).fill("");

  let li = 0; // visible-letter index (skips the space)
  for (const ch of WORD) {
    if (ch === " ") {
      for (let r = 0; r < ROWS; r++) rows[r] += " ".repeat(WORD_GAP);
      continue;
    }
    const hue = (0.55 + li * 0.08) % 1;
    const [r, g, b] = hslToRgb(hue, 0.85, 0.6);
    const fg = rgbFg(r, g, b);
    const glyph = GLYPHS[ch]!;
    for (let r = 0; r < ROWS; r++) {
      const glyphRow = glyph[r]!;
      if (li > 0) rows[r] += " ".repeat(LETTER_GAP);
      rows[r] += glyphRow.trim() === "" ? " ".repeat(glyphRow.length) : fg + glyphRow + RESET;
    }
    li++;
  }

  // Subtitle (muted blue-grey, like the splash's subtitle)
  const [sr, sg, sb] = hslToRgb(0.58, 0.3, 0.55);
  const subtitle = `${rgbFg(sr, sg, sb)}${SUBTITLE}${RESET}`;

  const all = [...rows, "", `  ${subtitle}`];
  const maxW = Math.max(...all.map((l) => visibleWidth(l)));
  const target = Math.min(width, maxW);
  return all.map((l) => (visibleWidth(l) > target ? truncateToWidth(l, target) : l));
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setHeader((_tui, _theme) => ({
      render(width: number): string[] {
        return renderArt(width);
      },
      invalidate() {},
    }));
  });

  pi.registerCommand("builtin-header", {
    description: "Restore the built-in startup header",
    handler: async (_args, ctx) => {
      ctx.ui.setHeader(undefined);
      ctx.ui.notify("Built-in header restored", "info");
    },
  });
}
