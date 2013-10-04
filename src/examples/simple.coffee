cluster = require "cluster"
{DEventEmitter, DEventData} = devent = require "../devent"
messages = require "./messages"

WORKERS = 2

startMaster = ->
  cluster.fork() for i in [1..WORKERS]
  console.log "Start #{WORKERS} worker processes"

startWorker = ->
  console.log "Start worker ##{cluster.worker.id}"

  options =
    ID: cluster.worker.id
  devent.config options

  emitter = new DEventEmitter()

  emitter.on "ping", (source, data, event) ->
    message = data.parse()
    console.log "Emitter #{emitter.id} received event from #{source.id}:"
    console.log "Message #{data.id}: count: #{message.count} message: #{message.message}"
    console.log "=="

    # Send response to source
    if message.count > 0
      response = DEventData.createFromMessage messages.PING,
        count: message.count - 1
        message: "Ping from #{emitter.name}"
      source.emit "ping", emitter.id, response
    else
      # Stop emitter
      console.log "Emitter #{emitter.id} received final message"

  # Send ping message to other emitters
  emitter.register "simple_emitter_#{cluster.worker.id}"
  for i in [1..WORKERS]
    if i != cluster.worker.id
      emitter.resolve "simple_emitter_#{i}", (error, source) ->
        response = DEventData.createFromMessage message.PING,
          count: 10
          message: "Ping from #{emitter.name}"
        source.emit "ping", emitter.id, response

main = ->
  if cluster.isMaster
    startMaster()
  else
    startWorker()

main()
