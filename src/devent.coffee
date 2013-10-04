## Module dependencies
cluster = require "cluster"
{EventEmitter} = require "events"
{Event, EventData} = require "./messages"
settings = require "./settings"

class DEventEmitterId

  @_nextId = 1

  @create: (workerId, emitterId) ->

  constructor: (data) ->
    unless data?
      data = settings.ID << 24 | DEventEmitterId._nextId++
    @data = data

  toNumber: ->
    @data

  isLocal: ->
    @data >> 24 == settings.ID

  emit: (event, source, message) ->
    # TODO
    # 1. Need some validation
    # -- Wu Yuntao, 2013-10-04
    DEventEmitterManager.instance.emit "newEvent", new DEvent(source, this, event, message)

class DEventEmitterManager extends EventEmitter

  constructor: ->
    super
    @_emitters = {}
    @_namedEmitters = {}
    @on "newEmitter", (emitter) =>
      id = emitter.id.toNumber()
      if id of @_emitters
        # TODO
        # 1. Use custom exception
        # -- Wu Yuntao, 2013-10-04
        return emitter.__emit "error", new Error("Id is not already exists")

      @_emitters[id] = emitter

    @on "removeEmitter", (emitter) =>
      id = emitter.id.toNumber()
      unless id of @_emitters
        # TODO
        # 1. Use custom exception
        # -- Wu Yuntao, 2013-10-04
        return emitter.__emit "error", new Error("Id not found")

      @_emitters[id] = emitter

    @on "registerName", (emitter) =>
      if not emitter.name
        return emitter.__emit "error", new Error("Invalid name")

      if emitter.name of @_namedEmitters
        return emitter.__emit "error", new Error("Duplicate name")

      @_emitters[emitter.name] = emitter

    @on "unregisterName", (emitter) =>
      if not emitter.name
        return emitter.__emit "error", new Error("Invalid name")

      unless emitter.name of @_namedEmitters
        return emitter.__emit "error", new Error("Name not found")

      del @_emitters[emitter.name]

    @on "newEvent", (event) =>
      target = event.target.toNumber()
      emitter = @_emitters[target]
      # TODO
      # 1. Need some validation
      # -- Wu Yuntao, 2013-10-04
      unless emitter?
        # TODO
        # 1. Send message or custom event instead of error?
        # -- Wu Yuntao, 2013-10-04
        if event.source.isLocal()
          event.source.__emit "error", new Error("Target is dead")
        else
          console.log "Sending event to remote emitter is not implemented"
        return

      target.__emit event.type, event.data, event

DEventEmitterManager.instance = new DEventEmitterManager()

class DEventEmitter extends EventEmitter

  constructor: ->
    super
    @id = DEventEmitterId.create()
    @isDestroyed = false
    DEventEmitterManager.instance.emit "newEmitter", this

  # Original emit method is not exposed to users
  __emit: @prototype.emit

  emit: (event, source, message) ->
    @id.emit event, source, message

  register: (name) ->
    # TODO
    # 1. Use custom exception
    # -- Wu Yuntao, 2013-10-04
    throw new Error("Name is already registered") if @name

    DEventEmitterManager.instance.emit "registerName", this

  unregister: ->
    # TODO
    # 1. Use custom exception
    # -- Wu Yuntao, 2013-10-04
    throw new Error("Name is not defined") unless @name

    DEventEmitterManager.instance.emit "unregisterName", this

  destroy: ->
    return if @isDestroyed
    @isDestroyed = true
    DEventEmitterManager.instance.emit "removeEmitter", this

class DEvent

  @deserialize = (buffer) ->
    event = Event.parse buffer
    source = DEventEmitterId.parse event.source
    target = DEventEmitterId.parse event.target
    type = event.type.name
    data = new DEventData event.data
    new DEvent(source, target, type, data)

  constructor: (@source, @target, @type, @data) ->

class DEventData

  @_parsers: {}

  @register: (id, parser) ->
    if id of @_parsers
      # TODO
      # 1. Throw custom exception
      # -- Wu Yuntao, 2013-10-04
      throw new Error("ID conflict")

    @_parsers[id] = parser
    return

  @parser: (id) ->
    parser = @_parsers[data.id]
    # TODO
    # 1. Throw custom exception
    # -- Wu Yuntao, 2013-10-04
    throw new Error("Parser not found. id: #{data.id}") unless parser?
    parser

  @createFromData: (id, raw) ->
    new DEventData id: id, raw: raw

  @createFromMessage: (id, message) ->
    new DEventData id: id, message: message

  constructor: (data={}) ->
    @id = data.id
    @raw = data.raw
    @message = data.message

  parse: ->
    return @message if @message?
    @message = DEventData.parser(@id).parse this

  serialize: ->
    return @raw if @raw?
    @raw = DEventData.parser(@id).serialize this

## Exports
exports.version = "0.0.1"

exports.DEventEmitter = DEventEmitter

exports.DEventData = DEventData

exports.config = settings.config
