-- Migrated from hyprland.conf (hyprlang) to the Lua config API.
-- Original kept at hyprland.conf.bak
-- Ref: /usr/share/hypr/hyprland.lua, https://wiki.hypr.land/Configuring/Start/

--------------------
---- MONITOR(S) ----
--------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1664",
    position = "0x0",
    scale    = 1.6,
})

--------------
---- VARS ----
--------------

local control  = "SUPER" -- was $control
local command  = "CTRL"  -- was $command
local terminal = "kitty"
local menu     = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function ()
    hl.exec_cmd("ydotoold")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swayosd-server --top-margin 0.95")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprsunset --temperature 4100") -- warm up display

    -- bootstrap startup apps
    hl.exec_cmd("vivaldi",                        { workspace = "1 silent" })
    hl.exec_cmd("flatpak run md.obsidian.Obsidian", { workspace = "4 silent" })
    hl.exec_cmd("kitty",                          { workspace = "3" })

    -- audio device setup (Asahi jack)
    hl.exec_cmd("pactl set-card-profile 46 HiFi && pactl set-default-source effect_output.j413-mic && pactl set-source-mute effect_output.j413-mic 0 && pactl set-source-volume effect_output.j413-mic 150% && amixer -c 1 cset name='Jack ADC PGA' 24 && amixer -c 1 cset name='Jack ADC Preamp' 2")

    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

------------------------------
---- ENVIRONMENT VARIABLES ----
------------------------------

hl.env("WLR_DRM_NO_MODIFIERS", "1")
hl.env("XCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

---------------
---- COLORS ----
---------------

-- from ~/.config/colors/hyprland-colors.conf
local background = "rgba(1C1A14ee)"
local text       = "rgb(68694F)"
local accent     = "rgb(737458)"
local inactive   = "rgb(2C2A24)"
local urgent     = "rgb(f53c3c)"

---------------------
---- KEYBINDINGS ----
---------------------

-- general
hl.bind(control .. " + W",      hl.dsp.window.close())
hl.bind("SUPER + space",        hl.dsp.exec_cmd(menu))
hl.bind("SUPER + V",            hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"))
hl.bind(control .. " + D",      hl.dsp.exec_cmd("~/.scripts/rofi-dict.sh"))

-- script binds
hl.bind("SUPER + SHIFT + S",    hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SUPER + SHIFT + P",    hl.dsp.exec_cmd("~/.config/waybar/scripts/colorpicker.sh"))
hl.bind("SUPER + SHIFT + R",    hl.dsp.exec_cmd("~/.config/hypr/scripts/screenrecord.sh"))
hl.bind("SUPER + SHIFT + C",    hl.dsp.exec_cmd("~/.config/hypr/scripts/camoverlay.sh"))
hl.bind("SUPER + SHIFT + T",    hl.dsp.exec_cmd("~/.config/hypr/scripts/voice-agent.sh"))

-- lock screen
hl.bind(control .. " + L",      hl.dsp.exit())

-- toggle waybar
hl.bind(control .. " + M",      hl.dsp.exec_cmd("pkill waybar || (waybar &)"))

-- window management
hl.bind("ALT + h",              hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + l",              hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + j",              hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + k",              hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + o",              hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + i",              hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

hl.bind("ALT + SHIFT + H",      hl.dsp.window.resize({ x = -60, y = 0, relative = true }))
hl.bind("ALT + SHIFT + L",      hl.dsp.window.resize({ x = 60,  y = 0, relative = true }))
hl.bind("ALT + SHIFT + K",      hl.dsp.window.resize({ x = 0, y = -60, relative = true }))
hl.bind("ALT + SHIFT + J",      hl.dsp.window.resize({ x = 0, y = 60, relative = true }))

hl.bind("ALT + mouse:272",      hl.dsp.window.drag(), { mouse = true })

-- workspace management
for i = 1, 5 do
    hl.bind(control .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("ALT + " .. i,         hl.dsp.window.move({ workspace = i }))
end

-- scratchpad
hl.bind("SUPER + grave",          hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("ALT + grave",            hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- media keys
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"))
--hl.bind("XF86AudioMute",       hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("~/.config/hypr/scripts/transcribe.sh")) -- whisper
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh down"))
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh up"))
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- camera overlay window overrides
hl.window_rule({
    name  = "camera-overlay",
    match = { title = "^camera-overlay$" },
    float       = true,
    border_size = 3,
    pin         = true,
    move        = {1200, 100},
    opacity     = "1.0 1.0 override override",
})

-- always open windows on correct workspaces
hl.window_rule({ name = "ws-vivaldi-snapshot", match = { class = "^vivaldi-snapshot.*" }, workspace = "1" })
hl.window_rule({ name = "ws-vivaldi-ompi",     match = { class = "^vivaldi-ompi.*" },     workspace = "2" })
hl.window_rule({ name = "ws-kitty",            match = { class = "kitty" },               workspace = "3" })
hl.window_rule({ name = "ws-obsidian",         match = { class = "obsidian" },            workspace = "4" })

-- layer rules (blur off)
hl.layer_rule({ name = "rofi-blur",    match = { namespace = "rofi" },    blur = false, ignore_alpha = 0 })
hl.layer_rule({ name = "waybar-blur",  match = { namespace = "waybar" },  blur = false, ignore_alpha = 0 })
hl.layer_rule({ name = "swayosd-rules",match = { namespace = "swayosd" }, blur = false, ignore_alpha = 0 })

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        layout           = "dwindle",
        resize_on_border = true,
        gaps_in          = 2,
        gaps_out         = { top = 10, right = 10, bottom = 10, left = 10 },
        border_size      = 3,
        col = {
            active_border   = accent,
            inactive_border = inactive,
        },
		},

--    scrolling = {
--        direction     = "up", -- scroll vertically instead of horizontally
--        column_width  = 0.9,
--    },

    dwindle = {
        preserve_split = true,
    },

    cursor = {
        no_hardware_cursors = true,
        no_warps            = true,
        inactive_timeout    = 0,
    },

    decoration = {
        shadow = {
            enabled      = false,
            range        = 30,
            render_power = 9,
            color        = "rgba(1a1a1a66)",
        },

        -- transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        rounding         = 10,

        blur = {
            enabled           = false,
            size              = 5,
            passes            = 4,
            new_optimizations = false,
            vibrancy          = 0.0,
            ignore_opacity    = true,
            special           = true,
            popups            = false,
        },

        -- screen_shader = "~/.config/hypr/shaders/crt.glsl",
    },

    animations = {
        enabled = false,
    }
})

hl.animation({ leaf = "windows",          enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "border",           enabled = false })
hl.animation({ leaf = "fade",             enabled = false })
hl.animation({ leaf = "workspaces",       enabled = false, speed = 3, bezier = "default" })
hl.animation({ leaf = "specialWorkspace",    enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "default", style = "slidevert" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_options  = "caps:swapescape", -- ctrl:swap_lwin_lctl
        follow_mouse = 0,

        touchpad = {
            tap_to_click         = false,
            natural_scroll       = true,
            clickfinger_behavior = true,
            drag_lock            = true,
            scroll_factor        = 0.25,
            disable_while_typing = true,
        },
    },
})

-------------
---- GESTURES ----
-------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up",   action = "special", workspace_name = "scratchpad" })
hl.gesture({ fingers = 3, direction = "down", action = "special", workspace_name = "scratchpad" })

-- Ignore maximize requests from apps:
-- local suppressMaximize = hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland:
-- hl.window_rule({
--     name  = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, floating = true, fullscreen = false, pinned = true },
--     no_focus = true,
-- })
