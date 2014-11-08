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

base = 'http://127.0.0.1:3000'

urls =
  todo: (todo) -> "#{base}/todos/#{todo.id}"
  todos: -> "#{base}/todos"
  markComplete: (todo) -> "#{base}/todos/#{todo.id}/mark_complete"
  markActive: (todo) -> "#{base}/todos/#{todo.id}/mark_active"

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

app.get '/todos', (req, res) ->
  # res.redirect urls.todos()
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

app.listen(3000);