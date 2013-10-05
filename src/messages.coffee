## Module dependencies
fs = require "fs"
path = require "path"
{Schema} = require "protobuf"

schema = new Schema fs.readFileSync(path.join(__dirname, "../messages/devents.desc"))

exports.EmitterID = schema["devents.Emitter"]
exports.EventType = schema["devents.EventType"]
exports.EventData = schema["devents.EventData"]
exports.Event     = schema["devents.Event"]
