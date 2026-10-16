from libqtile.config import Key, Click, Drag
from libqtile.lazy import lazy
import os

os.environ["PATH"] = os.path.expanduser("~/.local/bin") + ":" + os.environ.get("PATH", "")

power_menu = "rofi -show power-menu -modi power-menu:rofi-power-menu"
explorer = "thunar"
mod = "mod4"
terminal = "alacritty"
menu = "rofi -show drun"
menu_t = "rofi -show window"
screenshot = "flameshot gui"
full_screenshot = f"flameshot full -p {os.path.expanduser('~/Pictures')}"

def window_to_next_group(qtile):
    win = qtile.current_window
    if win is None:
        return
    i = qtile.groups.index(qtile.current_group)
    win.togroup(qtile.groups[(i + 1) % len(qtile.groups)].name, switch_group=True)

def window_to_prev_group(qtile):
    win = qtile.current_window
    if win is None:
        return
    i = qtile.groups.index(qtile.current_group)
    win.togroup(qtile.groups[(i - 1) % len(qtile.groups)].name, switch_group=True)

keys = [
    Key([mod, "shift"], "s", lazy.spawn(screenshot), desc="Take a screenshot"),
    Key([mod, "shift"], "d", lazy.spawn(full_screenshot), desc="Take a screenshot"),

    Key([mod], "e", lazy.spawn(explorer), desc="Open file explorer"),
    Key([mod], "q", lazy.spawn(power_menu), desc="Open power menu"),

    Key(["mod1", "control", "shift"], "Right", lazy.function(window_to_next_group)),
    Key(["mod1", "control", "shift"], "Left", lazy.function(window_to_prev_group)),

    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    #Key(["mod1"], "tab", lazy.layout.next(), desc="Move window focus to next window"),
    Key(["mod1"], "Tab", lazy.spawn(menu_t), desc="Switch through windows"),

    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),


    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),


    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "p", lazy.spawn(menu), desc="Launch menu"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),   
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),

    Key([mod, "control"], "Right", lazy.screen.next_group(), "Switch to next workspace"),
    Key([mod, "control"], "Left", lazy.screen.prev_group(), "Switch to next workspace"),

    Key([mod, "shift"], "m", lazy.window.toggle_minimize(), desc="Minimize window"),
    Key([mod, "shift"], "u", lazy.group.unminimize_all(), desc="Restore minimized"),
]

# Drag floating layouts
bring_front_click = "floating_only"
mouse = [
    Drag(["mod1"], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag(["mod1"], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
]
