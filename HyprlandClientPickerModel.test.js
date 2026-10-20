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
assert.equal(Array.from(model.dispatchClient(clients[0], false)).at(-1),
  "focus_or_launch({ match = '0xab12', field = 'address' })")
assert.equal(Array.from(model.dispatchClient(clients[0], true)).at(-1),
  "fetch_or_launch({ match = '0xab12', field = 'address' })")
console.log('Hyprland client picker model: OK')
