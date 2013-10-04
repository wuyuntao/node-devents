fs = require "fs"
path = require "path"
{Schema} = require "protobuf"
{DEventData} = require "../devent"

schema = new Schema fs.readFileSync(path.join(__dirname, "../../messages/devent_examples.desc"))

exports.PING = 1000

## Message definitions
DEventData.register exports.PING, schema["devent.examples.Ping"]
