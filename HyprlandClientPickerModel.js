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
  if (!query.trim()) return clients
  var words = query.toLowerCase().trim().split(/\s+/)
  return clients.map(function(client, index) {
    var text = (String(client.title || "") + " " + String(client.class || "")).toLowerCase()
    var score = 0
    if (words.length === 1) {
      var position = -1
      var previousPosition = -1
      for (var i = 0; i < words[0].length; i++) {
        position = text.indexOf(words[0][i], position + 1)
        if (position < 0) return null
        if (position === 0 || /[\s_-]/.test(text[position - 1])) score += 10
        if (position === previousPosition + 1) score += 5
        score -= position
        previousPosition = position
      }
      if (text.includes(words[0])) score += 100
    } else {
      var clientWords = text.split(/[^a-z0-9]+/).filter(function(word, index, allWords) {
        return word && allWords.indexOf(word) === index
      })
      var used = {}
      for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
        var bestScore = null
        var bestWordIndex = -1
        for (var clientWordIndex = 0; clientWordIndex < clientWords.length; clientWordIndex++) {
          if (used[clientWordIndex]) continue
          var matchPosition = -1
          var previousMatchPosition = -1
          var matchScore = 0
          for (var charIndex = 0; charIndex < words[wordIndex].length; charIndex++) {
            matchPosition = clientWords[clientWordIndex].indexOf(words[wordIndex][charIndex], matchPosition + 1)
            if (matchPosition < 0) { matchScore = null; break }
            if (matchPosition === 0) matchScore += 10
            if (matchPosition === previousMatchPosition + 1) matchScore += 5
            matchScore -= matchPosition
            previousMatchPosition = matchPosition
          }
          if (matchScore !== null && (bestScore === null || matchScore > bestScore)) {
            bestScore = matchScore
            bestWordIndex = clientWordIndex
          }
        }
        if (bestScore === null) return null
        used[bestWordIndex] = true
        score += bestScore
      }
    }
    return { client: client, index: index, score: score }
  }).filter(function(match) {
    return match !== null
  }).sort(function(a, b) {
    return b.score - a.score || a.index - b.index
  }).map(function(match) {
    return match.client
  })
}

function dispatchClient(client, fetch) {
  // The address is validated in parseClients, before it enters the Lua dispatcher.
  return ["hyprctl", "dispatch", (fetch ? "fetch_or_launch" : "focus_or_launch")
    + "({ match = '" + client.address + "', field = 'address' })"]
}
