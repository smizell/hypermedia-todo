_ = require 'lodash'
{Storage} = require './lib/storage'
{RootResource, TodoResource, TodosResource} = require './lib/resources'

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

port = 3000
base = "http://127.0.0.1:#{port}"

# Used for example purposes, see README
todoServer = 'http://127.0.0.1:4000/api/todos'

urls =
  todo: (todo) -> "#{base}/api/todos/#{todo.id}"
  todos: -> "#{base}/api/todos"
  # todos: -> todoServer
  markComplete: (todo) -> "#{base}/api/todos/#{todo.id}/mark_complete"
  markActive: (todo) -> "#{base}/api/todos/#{todo.id}/mark_active"

express = require 'express'
cors = require 'cors'
bodyParser = require 'body-parser'
app = express()
storage = new Storage

app.use(cors())
app.use express.static(__dirname + '/public')
app.use bodyParser.json()

# Add our content type
app.use (req, res, next) ->
  res.set 'Content-Type', 'application/vnd.smizell.hypermedia+json'
  next()

app.get '/api', (req, res) ->
  root = new RootResource contextBuilder(), storage
  res.send root.show()

app.get '/api/todos', (req, res) ->
  todos = new TodosResource contextBuilder(), storage
  res.send todos.list()

app.post '/api/todos', (req, res) ->
  todos = new TodosResource contextBuilder(title: req.body.title), storage
  res.send todos.create()

app.get '/api/todos/:id', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.show()

app.delete '/api/todos/:id', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.remove()

app.post '/api/todos/:id/mark_complete', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.markComplete()

app.post '/api/todos/:id/mark_active', (req, res) ->
  context = contextBuilder(id: parseInt(req.params.id))
  todo = new TodoResource context, storage
  res.send todo.markActive()

app.get '*', (req, res) ->
  res.sendFile __dirname + '/public/index.html'

app.listen(3000);
