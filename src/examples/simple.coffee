cluster = require "cluster"
{DEventEmitter} = devent = require "../devent"

WORKERS = 2

class PingMessage

  constructor(@count, @message)

  toString: ->
    return "PingMessage[@count=#{@count}, @message=#{@message}]"


startMaster = ->
  cluster.fork() for i in [1..WORKERS]
  console.log "Start #{WORKERS} worker processes"

startWorker = ->
  console.log "Start worker ##{cluster.worker.id}"

  options =
    ID: cluster.worker.id
  devent.initialize options

  emitter = new DEventEmitter()

  emitter.on "ping", (source, message) ->
    console.log "Emitter #{emitter.id} received event from #{source.id}: #{message.toString()}"
    # Send response to source
    if message.count > 0
      response = new PingMessage message.count - 1, "Ping from #{emitter.name}"
      emitter.emit source.id, "ping", response
    else
      # Stop emitter
      console.log "Emitter #{emitter.id} received final message"

  # Send ping message to other emitters
  emitter.register "simple_emitter_#{cluster.worker.id}", (error) ->
    for i in [1..WORKERS]
      if i != cluster.worker.id
        message = new PingMessage 10, "Ping from #{emitter.name}"
        emitter.emit "simple_emitter_#{i}", "ping", message
    return

main = ->
  if cluster.isMaster
    startMaster()
  else
    startWorker()

main()
