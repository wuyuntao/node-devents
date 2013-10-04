## Module dependencies
fs = require "fs"
path = require "path"
{Schema} = require "protobuf"

schema = new Schema fs.readFileSync(path.join(__dirname, "../messages/devent.desc"))

exports.EmitterID = schema["devent.Emitter"]
exports.EventType = schema["devent.EventType"]
exports.EventData = schema["devent.EventData"]
exports.Event     = schema["devent.Event"]
