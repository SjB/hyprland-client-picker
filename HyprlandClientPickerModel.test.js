const assert = require('node:assert/strict')
const fs = require('node:fs')
const vm = require('node:vm')

const model = {}
vm.runInNewContext(fs.readFileSync(__dirname + '/HyprlandClientPickerModel.js', 'utf8'), model)
const clients = model.parseClients(JSON.stringify([
  { title: 'Notes', class: 'editor', address: '0xab12', hidden: false },
  { title: 'Secret', class: 'editor', address: '0xab13', hidden: true },
  { title: 'bad', class: 'editor', address: "0x1'; exit 1;", hidden: false },
]))

assert.equal(clients.length, 1)
assert.equal(model.parseClients('{broken'), null)
assert.equal(model.filterClients(clients, 'EDIT').length, 1)
assert.equal(model.filterClients(clients, 'secret').length, 0)
const fuzzyClients = [
  { title: 'Google Chrome', class: 'chrome' },
  { title: 'Chrome', class: 'chrome' },
  { title: 'Other', class: 'something' },
]
assert.deepEqual(Array.from(model.filterClients(fuzzyClients, 'chr')), [fuzzyClients[1], fuzzyClients[0]])
assert.deepEqual(Array.from(model.filterClients(fuzzyClients, 'gch')), [fuzzyClients[0]])
const wordStartClients = [
  { title: 'caraco: [2] hypn', class: 'terminal-herdr' },
  { title: 'NCA git - Chromium', class: 'chromium' },
]
assert.deepEqual(Array.from(model.filterClients(wordStartClients, 'ch')), [wordStartClients[1], wordStartClients[0]])
assert.deepEqual(Array.from(model.filterClients(wordStartClients, 'ca he')), [wordStartClients[0]])
assert.deepEqual(Array.from(model.filterClients(wordStartClients, 'c h')), [wordStartClients[0]])
assert.deepEqual(Array.from(model.filterClients(wordStartClients, 'c ')), wordStartClients)
assert.equal(Array.from(model.dispatchClient(clients[0], "fetch_or_launch")).slice(0, 2).join(" "),
  "hyprctl eval")
assert.equal(Array.from(model.dispatchClient(clients[0], "fetch_or_launch")).at(-1),
  "fetch_or_launch({ match = '0xab12', field = 'address' })")
assert.equal(Array.from(model.dispatchClient(clients[0], "move_to_monitor")).at(-1),
  "move_to_monitor({ match = '0xab12', field = 'address' })")
assert.equal(Array.from(model.dispatchClient(clients[0], "focus_or_launch")).at(-1),
  "focus_or_launch({ match = '0xab12', field = 'address' })")
console.log('Hyprland client picker model: OK')
