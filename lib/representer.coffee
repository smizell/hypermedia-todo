_ = require 'lodash'

# Generic method names
methods =
  get: 'GET'
  process: 'POST'
  delete: 'DELETE'

class Representer
  constructor: (@attributes={}) ->
    @transitions = {}
    @embedded = {}

  addTransition: (rel, href, method='get', attributes) ->
    unless rel of @transitions
      @transitions[rel] = []
    @transitions[rel].push
      href: href
      method: methods[method] if method != 'get'
      attributes: attributes if attributes
    @transitions[rel]

  toObject: -> {
    attributes: @attributes unless _.isEmpty(@attributes)
    transitions: @transitions
    embedded: @embedded unless _.isEmpty(@embedded)
  }

module.exports = {Representer}
