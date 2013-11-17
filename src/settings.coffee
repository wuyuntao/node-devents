settings =

  DEBUG: true

  ID: 1

  BIND_SOCKET: "tcp://0.0.0.0:3000"

  SEED_SOCKETS: [
    "tcp://0.0.0.0:3000"
  ]


  config: (options) ->
    for own key, value of options
      settings[key] = value
    settings

module.exports = settings
