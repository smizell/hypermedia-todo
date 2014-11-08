_ = require 'lodash'

# Initial list of todos
todoCollection = [
  {
    id: 1
    title: 'Get the milk'
    status: 'active'
  }
  {
    id: 2
    title: 'Pay bills'
    status: 'active'
  }
]

class Storage
  getTodos: (cb) ->
    cb null, todoCollection

  getTodo: (id, cb) ->
    cb null, _.first(_.filter(todoCollection, id: id))

  createTodo: (title, cb) ->
    todo =
      id: Date.now() # crude way to get unique id
      title: title
      status: 'active'
    todoCollection.push todo
    cb null, todo

  updateTodo: (id, values, cb) ->
    @getTodo id, (err, todo) ->
      _.extend todo, values
      cb null, todo

  deleteTodo: (id, cb) ->
    todo = @getTodo id, ->
      todoCollection = _.filter todoCollection, (todo) ->
        todo.id != id
      cb null, todoCollection

module.exports = {Storage}
