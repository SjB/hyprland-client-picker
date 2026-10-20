// Keep Hyprland client selection and dispatch arguments separate from the QML view.
function parseClients(json) {
  try {
    var clients = JSON.parse(json)
    if (!Array.isArray(clients)) return null
    return clients.filter(function(client) {
      return client && client.hidden === false && /^0x[0-9a-f]+$/i.test(client.address)
    })
  } catch (e) {
    return null
  }
}

function filterClients(clients, query) {
  var needle = query.toLowerCase()
  return clients.filter(function(client) {
    return (String(client.title || "") + " " + String(client.class || "")).toLowerCase().includes(needle)
  })
}

function dispatchClient(client, fetch) {
  // The address is validated in parseClients, before it enters the Lua dispatcher.
  return ["hyprctl", "dispatch", (fetch ? "fetch_or_launch" : "focus_or_launch")
    + "({ match = '" + client.address + "', field = 'address' })"]
}
