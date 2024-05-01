from libqtile.config import Key, Click, Drag
from libqtile.lazy import lazy


mod = "mod4"
terminal = "alacritty"
menu = "rofi -show run"
menu_t = "rofi -show window"

keys = [
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
]

# Drag floating layouts
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button1", lazy.window.bring_to_front()),
]
