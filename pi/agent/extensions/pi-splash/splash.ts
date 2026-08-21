/**
 * Splash screen animation component for pi
 *
 * Multi-phase animation:
 *   1. Border glow-in (0-500ms)
 *   2. Logo gradient sweep reveal (150-800ms)
 *   3. Subtitle fade-in (700-1200ms)
 *   4. Loading bar fill (1100-2200ms)
 *   5. Hold & fade-out (2800-3200ms)
 *
 * Dismiss on any keypress or auto-dismiss after ~3.2s.
 */

import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// ── pi logo ASCII art ──────────────────────────────────────────
const PI_LOGO: string[] = [
  "██████╗     ██╗",
  "██╔══██╗    ██║",
  "██████╔╝    ██║",
  "██╔═══╝     ██║",
  "██║         ██║",
  "╚═╝         ╚═╝",
];

const SUBTITLE = "coding agent harness";

// ── HSL → RGB ──────────────────────────────────────────────────
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
function reset(): string {
  return "\x1b[0m";
}

// ── Easing ─────────────────────────────────────────────────────
function easeOutCubic(t: number): number {
  return 1 - Math.pow(1 - t, 3);
}
function easeOutBack(t: number): number {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}
function easeInOutCubic(t: number): number {
  return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
}
function clamp(v: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, v));
}

const SPARKLES = ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"];

// ── Component ──────────────────────────────────────────────────
export class SplashComponent {
  private tui: { requestRender: () => void };
  private done: () => void;
  private startTime: number;
  private frame = 0;
  private interval: ReturnType<typeof setInterval> | null = null;
  private autoDismissTimeout: ReturnType<typeof setTimeout> | null = null;
  private dismissed = false;

  // Caching
  private cachedWidth = 0;
  private cachedFrame = -1;
  private cachedLines: string[] = [];

  constructor(tui: { requestRender: () => void }, _theme: unknown, done: () => void) {
    this.tui = tui;
    this.done = done;
    this.startTime = Date.now();

    this.interval = setInterval(() => {
      if (this.dismissed) return;
      this.frame++;
      this.tui.requestRender();
    }, 1000 / 50);

    this.autoDismissTimeout = setTimeout(() => {
      if (!this.dismissed) this.dismiss();
    }, 3200);
  }

  private dismiss(): void {
    if (this.dismissed) return;
    this.dismissed = true;
    this.dispose();
    this.done();
  }

  handleInput(_data: string): void {
    if (!this.dismissed) this.dismiss();
  }

  invalidate(): void {
    this.cachedWidth = 0;
  }

  dispose(): void {
    if (this.interval) { clearInterval(this.interval); this.interval = null; }
    if (this.autoDismissTimeout) { clearTimeout(this.autoDismissTimeout); this.autoDismissTimeout = null; }
  }

  render(width: number): string[] {
    if (this.dismissed) return [];
    if (this.cachedWidth === width && this.cachedFrame === this.frame) return this.cachedLines;

    const elapsed = (Date.now() - this.startTime) / 1000;

    // ── Animation progress (0→1) ────────────────────────────
    const borderGlow = clamp(easeOutBack(elapsed / 0.5), 0, 1);
    const logoProgress = clamp(easeOutCubic((elapsed - 0.15) / 0.55), 0, 1);
    const subtitleProgress = clamp(easeOutCubic((elapsed - 0.7) / 0.45), 0, 1);
    const barProgress = clamp(easeInOutCubic((elapsed - 1.1) / 0.9), 0, 1);

    let alpha = 1;
    if (elapsed > 2.8) alpha = clamp(1 - (elapsed - 2.8) / 0.4, 0, 1);
    if (alpha <= 0) return [];

    // ── Layout ───────────────────────────────────────────────
    const boxWidth = Math.min(width - 4, 62);
    const innerW = boxWidth - 2;
    const leftPad = Math.floor((width - boxWidth) / 2);

    const padToWidth = (line: string): string => {
      const vw = visibleWidth(line);
      if (vw >= width) return truncateToWidth(line, width);
      return line + " ".repeat(width - vw);
    };

    // ── Color helpers ────────────────────────────────────────
    const borderColor = (s: string): string => {
      const hue = (elapsed * 0.08 + 0.55) % 1;
      const lit = 0.3 + borderGlow * 0.3;
      const [r, g, b] = hslToRgb(hue, 0.5, lit);
      return rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha)) + s + reset();
    };

    const charColor = (i: number, _total: number, progress: number): string => {
      const hue = (0.55 + i * 0.08 + elapsed * 0.15) % 1;
      const lit = 0.25 + progress * 0.5;
      const [r, g, b] = hslToRgb(hue, 0.85, lit);
      return rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha));
    };

    const dimColor = (s: string): string => {
      const [r, g, b] = hslToRgb(0, 0, 0.4);
      return rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha)) + s + reset();
    };

    const lines: string[] = [];

    // ── Top border ───────────────────────────────────────────
    lines.push(
      padToWidth(
        " ".repeat(leftPad) + borderColor("╭") + borderColor("─".repeat(innerW)) + borderColor("╮"),
      ),
    );

    const innerLine = (content: string): string => {
      const padded = content + " ".repeat(Math.max(0, innerW - visibleWidth(content)));
      return padToWidth(" ".repeat(leftPad) + borderColor("│") + padded + borderColor("│"));
    };

    lines.push(innerLine(""));

    // ── Logo rows ───────────────────────────────────────────
    for (let row = 0; row < PI_LOGO.length; row++) {
      const logoLine = PI_LOGO[row]!;
      const rowDelay = row * 0.12;
      const rowProgress = clamp((logoProgress - rowDelay) / (1 - rowDelay), 0, 1);

      let colored = "";
      const chars = [...logoLine];
      for (let ci = 0; ci < chars.length; ci++) {
        const ch = chars[ci]!;
        if (ch === " ") { colored += " "; continue; }
        const charDelay = ci * 0.04;
        const cp = clamp((rowProgress - charDelay) / (1 - charDelay), 0, 1);
        if (cp > 0.05) {
          colored += charColor(ci, chars.length, cp) + ch + reset();
        } else {
          colored += " ";
        }
      }
      const logoVis = visibleWidth(colored);
      const logoPad = Math.max(0, Math.floor((innerW - logoVis) / 2));
      lines.push(innerLine(" ".repeat(logoPad) + colored));
    }

    lines.push(innerLine(""));

    // ── Subtitle ─────────────────────────────────────────────
    {
      const subChars = [...SUBTITLE];
      let subColored = "";
      for (let ci = 0; ci < subChars.length; ci++) {
        const ch = subChars[ci]!;
        if (ch === " ") { subColored += " "; continue; }
        const charDelay = ci * 0.03;
        const cp = clamp((subtitleProgress - charDelay) / (1 - charDelay), 0, 1);
        if (cp > 0.05) {
          const [r, g, b] = hslToRgb(0.58, 0.3, 0.4 + cp * 0.3);
          subColored += rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha)) + ch + reset();
        } else {
          subColored += " ";
        }
      }
      const subVis = visibleWidth(subColored);
      const subPad = Math.max(0, Math.floor((innerW - subVis) / 2));
      lines.push(innerLine(" ".repeat(subPad) + subColored));
    }

    lines.push(innerLine(""));

    // ── Loading bar ──────────────────────────────────────────
    {
      const barTotal = innerW - 8;
      const barFilled = Math.floor(barTotal * barProgress);
      const barEmpty = barTotal - barFilled;
      let barStr = "";

      for (let i = 0; i < barFilled; i++) {
        const t = i / Math.max(1, barTotal - 1);
        const hue = 0.55 + t * 0.15;
        const [r, g, b] = hslToRgb(hue, 0.9, 0.5);
        barStr += rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha)) + "█" + reset();
      }
      if (barFilled < barTotal && barProgress > 0) {
        const sparkleIdx = Math.floor((elapsed * 16) % SPARKLES.length);
        const tipHue = 0.55 + barProgress * 0.15;
        const [r, g, b] = hslToRgb(tipHue, 0.9, 0.65);
        barStr += rgbFg(Math.round(r * alpha), Math.round(g * alpha), Math.round(b * alpha)) + SPARKLES[sparkleIdx] + reset();
        for (let i = 1; i < barEmpty; i++) barStr += dimColor("░");
      } else {
        for (let i = 0; i < barEmpty; i++) barStr += dimColor("░");
      }

      const barPad = Math.max(0, Math.floor((innerW - barTotal) / 2));
      lines.push(innerLine(" ".repeat(barPad) + barStr));
    }

    // Fill remaining rows to consistent box height
    const currentInner = lines.length - 1; // minus top border
    for (let i = currentInner; i < 14; i++) {
      lines.push(innerLine(""));
    }

    // ── Bottom border ────────────────────────────────────────
    lines.push(
      padToWidth(
        " ".repeat(leftPad) + borderColor("╰") + borderColor("─".repeat(innerW)) + borderColor("╯"),
      ),
    );

    this.cachedLines = lines;
    this.cachedWidth = width;
    this.cachedFrame = this.frame;
    return lines;
  }
}
