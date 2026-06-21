-- ============================================================================
-- Hyprland Configuration
-- Based on dwm/config.h + .xinitrc setup
-- ============================================================================

-- Load split-monitor-workspaces plugin
package.path = package.path .. ";./?.lua;./?/init.lua"
local smw = require("plugins.split-monitor-workspaces")

------------------
--  MONITORS  --
------------------
-- HDMI-A-0 rotated right (from xrandr in .xinitrc)
-- Adjust monitor names based on your hardware:
--   `hyprctl monitors` to list available outputs
hl.monitor({
    output   = "HDMI-A-2",    -- 主显示器 (标准方向)
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = "HDMI-A-1",    -- 副显示器 (旋转)
    mode     = "preferred",
    position = "1920x0",       -- HDMI-A-2 右侧
    scale    = 1,
    transform = 3,              -- 3 = 270° 顺时针旋转
})
hl.monitor({
    output   = "WAYLAND-1",   -- 虚拟显示器
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
--  ENVIRONMENT  --
---------------------
-- Input method (same as .xinitrc)
hl.env("QT_IM_MODULE",   "fcitx")
hl.env("GTK_IM_MODULE",  "fcitx")
hl.env("SDL_IM_MODULE",  "fcitx")
hl.env("XMODIFIERS",     "@im=fcitx")
hl.env("GLFW_IM_MODULE", "ibus")

-------------------
--  AUTOSTART  --
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell &")
    hl.exec_cmd("fcitx5 -r &")
    hl.exec_cmd("emacs --daemon")
    hl.exec_cmd("hyprpaper &")

    -- Notification daemon (optional)
    -- hl.exec_cmd("dunst &")

    -- Network Manager applet (optional)
    -- hl.exec_cmd("nm-applet &")

    -- Polkit agent (optional)
    -- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &")

    -- Set wallpaper immediately (hyprpaper needs a config)
    -- hl.exec_cmd("hyprctl hyprpaper wallpaper ',~/Pictures/wallpaper/anime-girl-white-hair-4k-wallpaper-uhdpaper.com-148@5@h.jpg'")
end)

----------------------
--  LOOK & FEEL  --
----------------------
-- Colors from dwm/config.h:
--   col_gray1  = #222222  (bg)
--   col_gray2  = #444444  (inactive border)
--   col_gray3  = #bbbbbb  (fg)
--   col_gray4  = #ffffff  (selected fg)
--   col_cyan   = #37474F  (selected bg)
--   col_border = #42A5F5  (active border)

hl.config({
    general = {
        -- dwm gappx = 5 for both inner and outer gaps
        gaps_in  = 5,
        gaps_out = 10,

        -- dwm borderpx = 3
        border_size = 3,

        -- Gradient border (default hyprland style)
        col = {
            active_border   = { colors = {"rgb(ff0000)", "rgb(00ff00)", "rgb(0000ff)", "rgb(ff0000)"} },   -- gradient
            inactive_border = "rgb(444444)",                                                                    -- col_gray2
        },

        -- dwm-style: no window dragging on border click (like dwm's resize_on_border)
        resize_on_border = false,

        allow_tearing = false,

        -- dwm default layout is master-stack (tile), so use "master"
        layout = "master",
    },

    decoration = {
        -- Default rounded corners
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,   -- dwm has no shadows
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = false,      -- dwm has no blur
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        -- dwm has no animations, but minimal animations feel good
        enabled = true,
    },
})

-- Minimal animation curves (subtle, dwm-like feel)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })

-- Subtle animations only
hl.animation({ leaf = "global",     enabled = true,  speed = 8,    bezier = "default" })
hl.animation({ leaf = "windows",    enabled = true,  speed = 6,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true,  speed = 6,    bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true,  speed = 2,    bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fade",       enabled = true,  speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "workspaces", enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "border",     enabled = true,  speed = 5,    bezier = "easeOutQuint" })

-- Master layout settings (equivalent to dwm's tile layout)
hl.config({
    master = {
        -- dwm mfact = 0.55 (master area size factor)
        -- In Hyprland, master layout uses mfact too (0.5 = 50%)
        mfact = 0.55,
        -- dwm nmaster = 1 (number of master windows)
        -- In Hyprland, you can set orientation, but nmaster equivalent is per-workspace
        new_status = "master",
        -- Keep master on left side, like dwm
        orientation = "left",
    },
})

-- Setup split-monitor-workspaces
smw.setup({
    workspace_count = 5,
    enable_persistent_workspaces = true,
    enable_wrapping = true,
})

--------------
--  INPUT  --
--------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        -- ctrl:nocaps from .xinitrc (setxkbmap -option ctrl:nocaps)
        kb_options = "ctrl:nocaps",
        kb_rules   = "",

        follow_mouse = 1,

        -- xset r rate 200 50 from .xinitrc
        repeat_rate = 50,
        repeat_delay = 200,

        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
            tap_to_click   = true,
        },
    },
})

-- Touchpad gesture: 3-finger swipe for workspace switching
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


---------------------
--  KEYBINDINGS  --
---------------------
-- migrate from dwm/config.h:
--   MODKEY = Mod4Mask = SUPER (Windows key)

local M = "SUPER"

-- ==========================================
-- Launchers & Applications
-- ==========================================

-- dwm: Super + Return → st -e fish   (termcmd)
hl.bind(M .. " + Return", hl.dsp.exec_cmd("kitty"))

-- dwm: Super + P → dmenu_run   (dmenucmd)
-- Using wofi as dmenu replacement on Wayland.
-- If you prefer fuzzel/rofi, replace below.
hl.bind(M .. " + P", hl.dsp.exec_cmd("rofi -show run"))

-- dwm: Super + E → emacsclient -c   (emacscmd)
hl.bind(M .. " + E", hl.dsp.exec_cmd("emacsclient -c"))

-- ==========================================
-- Window Management
-- ==========================================

-- dwm: Super + J → focusstack +1   (next window)
hl.bind(M .. " + J", hl.dsp.layout("cyclenext"))

-- dwm: Super + K → focusstack -1   (prev window)
hl.bind(M .. " + K", hl.dsp.layout("cycleprev"))

-- dwm: Super + Shift + Return → zoom (swap focused with master)
hl.bind(M .. " + SHIFT + Return", hl.dsp.layout("swapwithmaster"))  -- master layout

-- dwm: Super + Shift + C → killclient
hl.bind(M .. " + SHIFT + C", hl.dsp.window.close())

-- Mod + M → toggle fullscreen
hl.bind(M .. " + M", hl.dsp.window.fullscreen())

-- Mod + F → toggle floating
hl.bind(M .. " + F", hl.dsp.window.float())

-- ==========================================
-- Workspaces (split-monitor-workspaces)
-- ==========================================

-- Super + 1-5 → switch to Nth workspace on current monitor
-- Super + Shift + 1-5 → move window to Nth workspace on current monitor
for i = 1, smw.get_amount_of_workspaces() do
    local key = tostring(i)
    hl.bind(M .. " + " .. key, smw.workspace(key))
    hl.bind(M .. " + SHIFT + " .. key, smw.move_to_workspace_silent(key))
end

-- Super + 0 → switch to last/previous workspace
hl.bind(M .. " + 0", hl.dsp.focus({ workspace = "previous" }))
hl.bind(M .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(M .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Super + , / . → focus previous / next monitor
hl.bind(M .. " + COMMA", hl.dsp.focus({ monitor = "-1" }))
hl.bind(M .. " + PERIOD", hl.dsp.focus({ monitor = "+1" }))

-- ==========================================
-- Exit / Quit
-- ==========================================

-- dwm: Super + Shift + Q → quit
hl.bind(M .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- ==========================================
-- Media Keys (from original autogenerated config)
-- ==========================================
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- ==========================================
-- Mouse Bindings
-- ==========================================

-- Super + 鼠标左键拖动 → 先浮动再拖拽
hl.bind(M .. " + mouse:272", function()
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.drag())
end, { mouse = true })

-- Super + 鼠标右键拖动 → 先浮动再调整大小
hl.bind(M .. " + mouse:273", function()
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.resize())
end, { mouse = true })


-----------------------
--  WINDOW RULES  --
-----------------------

-- Float some common dialogs
hl.window_rule({
    name  = "float-common-dialogs",
    match = {
        class = "",
        title = ".*",
        float = true,
    },
    no_focus = true,
})

-- Fix dragging issues with XWayland apps
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
