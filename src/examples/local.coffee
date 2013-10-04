###
# File: local.coffee
# Author: Wu Yuntao
# Created on: 2013-10-04
#
# 实现本地 Emitter 的互通
###

## Module dependencies
{DEventData, DEventEmitter} = require "../devent"
messages = require "./messages"

class PingPong extends DEventEmitter

  constructor: ->
    super

    @on "ping", (source, data, event) =>
      message = data.parse()
      console.log "=="
      console.log "##{@id}: received ping event from ##{source}: #{message.count}"
      if message.count > 0
        @pong source, message.count - 1
      else
        @final source

    @on "pong", (source, data, event) =>
      message = data.parse()
      console.log "=="
      console.log "##{@id}: received pong event from ##{source}: #{message.count}"
      if message.count > 0
        @ping source, message.count - 1
      else
        @final source

    @on "final", (source, data, event) ->
      message = data.parse()
      console.log "=="
      console.log "##{@id}: received final event from ##{source}"

  ping: (target, count) ->
    ping = DEventData.createFromMessage messages.PING,
      count: count
      message: "Ping from ##{@id}"
    target.emit "ping", @id, ping

  pong: (target, count) ->
    pong = DEventData.createFromMessage messages.PONG,
      count: count
      message: "Pong from ##{@id}"
    target.emit "pong", @id, pong

  final: (target) ->
    final = DEventData.createFromMessage messages.FINAL,
      message: "Final from ##{@id}"
    target.emit "final", @id, final

main = ->
  pp1 = new PingPong()
  pp2 = new PingPong()
  pp1.ping pp2.id, 10
  pp2.ping pp1.id, 10

main()
