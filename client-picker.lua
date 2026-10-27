-- Plugin-owned Hyprland Lua helpers; leave other configs' globals alone.
sjb_client_picker = sjb_client_picker or {}
local function find_matching_client(opts)
    local match = opts.match
    if not match then return end

    local field = opts.field or "class"
    local needle = string.lower(match)
    for _, client in ipairs(hl.get_windows()) do
        local value = client[field]
        if value and string.find(string.lower(value), needle, 1, true) then
            return client
        end
    end
end

local function move_and_focus_client(client, workspace_id)
    hl.dispatch(hl.dsp.window.move({
        workspace = tostring(workspace_id),
        follow = true,
        window = "address:" .. client.address,
    }))
    hl.dispatch(hl.dsp.focus({ window = "address:" .. client.address }))

    local moved = find_matching_client({ match = client.address, field = "address" })
    local layout = moved and moved.layout
    if layout and layout.name == "master" and not layout.is_master then
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
    end
end

sjb_client_picker.focus_or_launch = sjb_client_picker.focus_or_launch or function(opts)
    local client = find_matching_client(opts)
    if not client then
        hl.exec_cmd(opts.cmd)
        return
    end

    if opts.use_workspace ~= false and client.workspace and client.workspace.id then
        hl.dispatch(hl.dsp.focus({
            workspace = client.workspace.id,
            on_current_monitor = false,
        }))
    end
    hl.dispatch(hl.dsp.focus({ window = "address:" .. client.address }))

    local layout = client.layout
    if not (layout and layout.name == "master" and layout.is_master) then
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
    end
end

sjb_client_picker.fetch_or_launch = sjb_client_picker.fetch_or_launch or function(opts)
    local client = find_matching_client(opts)
    if not client then
        hl.exec_cmd(opts.cmd)
        return
    end

    local id = opts.workspace or hl.get_active_workspace().id
    move_and_focus_client(client, id)
end

sjb_client_picker.move_to_monitor = sjb_client_picker.move_to_monitor or function(opts)
    local monitor = hl.get_monitor(opts.monitor) or hl.get_active_monitor()
    local client = opts.match and find_matching_client(opts) or not opts.match and hl.get_active_window()
    if not monitor or not client then return end

    local ws_id = client.workspace and client.workspace.id
    if not ws_id or ws_id < 1 then return end

    local id = o.workspaces.workspace_id(monitor, ((ws_id - 1) % 10) + 1)
    move_and_focus_client(client, id)
end
