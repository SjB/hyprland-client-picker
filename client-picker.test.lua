focus_or_launch = function() end
local global = focus_or_launch
sjb_client_picker = { focus_or_launch = function() end }
local override = sjb_client_picker.focus_or_launch

dofile("client-picker.lua")
assert(focus_or_launch == global)
assert(sjb_client_picker.focus_or_launch == override)
assert(type(sjb_client_picker.fetch_or_launch) == "function")
assert(type(sjb_client_picker.move_to_monitor) == "function")

print("Hyprland client picker Lua namespace: OK")
