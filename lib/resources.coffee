_ = require 'lodash'
{Representer} = require './representer'

class TodoResource
  constructor: (@context, @storage) ->
    {@urls, @conditions, @id} = @context

  show: ->
    @storage.getTodo @id, (err, todo) =>
      url = @urls.todo todo
      rep = new Representer todo
      rep.addTransition 'self', url

      if @conditions.todo.edit
        rep.addTransition 'edit', url, 'process', title: todo.title

      if @conditions.todo.delete
        rep.addTransition 'delete', url, 'delete'

      if todo.status is 'active'
        if @conditions.todo.markComplete
          rep.addTransition 'markComplete', @urls.markComplete(todo), 'process'

      if todo.status is 'complete'
        if @conditions.todo.markActive
          rep.addTransition 'markActive', @urls.markActive(todo), 'process'

      rep

  markActive: ->
    @storage.updateTodo @id, status: 'active', (err, todo) =>
      todos = new TodosResource @context, @storage
      todos.list()

  markComplete: ->
    @storage.updateTodo @id, status: 'complete', (err, todo) =>
      todos = new TodosResource @context, @storage
      todos.list()

  remove: ->
    @storage.deleteTodo @id, =>
      todos = new TodosResource @context, @storage
      todos.list()

class TodosResource
  constructor: (@context, @storage) ->
    {@urls, @conditions, @title} = @context

  _buildTodoResource: (todo) ->
    context = {id: todo.id, @urls, @conditions}
    new TodoResource context, @storage

  create: ->
    @storage.createTodo @title, (err, todo) =>
      @list()

  list: ->
    @storage.getTodos (err, todos) =>
      rep = new Representer

      # Comment these remove links
      _.each todos, (todo) =>
       rep.addTransition 'todo', @urls.todo(todo)

      # Uncomment to embed
      # rep.embedded.todo = []
      # _.each todos, (todo) =>
      #   resource = @_buildTodoResource todo
      #   rep.embedded.todo.push resource.show()

      if @conditions.todo.create
        rep.addTransition 'create', @urls.todos(), 'process', title: null

      rep

module.exports = {
  TodoResource
  TodosResource
}
