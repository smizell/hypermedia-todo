_ = require 'lodash'
{Storage} = require './lib/storage'
{TodoResource, TodosResource} = require './lib/resources'

authenticate = ->
  name: 'Stephen Mizell'
  email: 'smizell@gmail.com'

authorize = ->
  todos:
    viewComplete: true
    viewActive: true
  todo:
    create: true
    edit: true
    delete: true
    markComplete: true
    markActive: true

contextBuilder = (options={}) ->
  user = authenticate()
  conditions = authorize(user)
  baseContext = {urls, conditions, user}
  _.extend {}, baseContext, options

urls =
  todo: (todo) -> "http://127.0.0.1:4000/todos/#{todo.id}"
  todos: -> 'http://127.0.0.1:4000/todos'
  markComplete: (todo) -> "http://127.0.0.1:4000/todos/#{todo.id}/mark_complete"
  markActive: (todo) -> "http://127.0.0.1:4000/todos/#{todo.id}/mark_active"

express = require 'express'
bodyParser = require 'body-parser'
cors = require 'cors'
app = express()
storage = new Storage


app.use(cors())
app.use(express.static(__dirname + '/public'));
app.use(bodyParser.json());

storage.createTodo 'On Server 2 now', ->

app.get '/todos', (req, res) ->
  todos = new TodosResource contextBuilder(), storage
  res.send todos.list()

app.post '/todos', (req, res) ->
  todos = new TodosResource contextBuilder(title: req.body.title), storage
  res.send todos.create()

app.get '/todos/:id', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.show()

app.delete '/todos/:id', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.remove()

app.post '/todos/:id/mark_complete', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.markComplete()

app.post '/todos/:id/mark_active', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.markActive()

app.get '*', (req, res) ->
  res.sendFile __dirname + '/public/index.html'

app.listen(4000);
