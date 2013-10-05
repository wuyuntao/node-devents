fs = require "fs"
path = require "path"
{Schema} = require "protobuf"
{DEventData} = require "../devents"

schema = new Schema fs.readFileSync(path.join(__dirname, "../../messages/examples.desc"))

BASE = 1000
exports.PING  = BASE
exports.PONG  = BASE + 1
exports.FINAL = BASE + 2

## Message definitions
DEventData.register exports.PING, schema["devents.examples.Ping"]
DEventData.register exports.PONG, schema["devents.examples.Pong"]
DEventData.register exports.FINAL, schema["devents.examples.Final"]
