settings =

  DEBUG: true

  ID: 1

  config: (options) ->
    for own key, value of options
      settings[key] = value
    settings

module.exports = settings
