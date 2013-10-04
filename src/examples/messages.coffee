fs = require "fs"
path = require "path"
{Schema} = require "protobuf"
{DEventData} = require "../devent"

schema = new Schema fs.readFileSync(path.join(__dirname, "../../messages/devent_examples.desc"))

BASE = 1000
exports.PING  = BASE
exports.PONG  = BASE + 1
exports.FINAL = BASE + 2

## Message definitions
DEventData.register exports.PING, schema["devent.examples.Ping"]
DEventData.register exports.PONG, schema["devent.examples.Pong"]
DEventData.register exports.FINAL, schema["devent.examples.Final"]
