/**
 * pi-splash — Cool startup splash screen for pi
 *
 * Multi-phase animated overlay on pi startup:
 *   • Animated border glow-in with elastic easing
 *   • Rainbow gradient logo character-by-character reveal
 *   • Subtitle fade-in
 *   • Gradient loading bar fill with pulsing sparkle tip
 *
 * Overlay mode — floats centered above pi's startup UI.
 * Dismiss on any keypress or auto-dismiss after ~3.2 seconds.
 *
 * Triggers only on actual startup (not /new, /resume, /reload, /fork).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { SplashComponent } from "./splash";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup") return;
    if (ctx.mode !== "tui") return;

    await new Promise((r) => setTimeout(r, 50));

    await ctx.ui.custom<void>(
      (tui, theme, _keybindings, done) =>
        new SplashComponent(tui, theme, done),
      {
        overlay: true,
        overlayOptions: {
          anchor: "center",
          width: 66,
          maxHeight: 22,
        },
      },
    );
  });
}
