_ = require 'lodash'
express = require 'express'
cors = require 'cors'
bodyParser = require 'body-parser'
app = express()

todos = [
  {
    id: 1,
    title: "Pay the bills"
    status: "active"
  }
  {
    id: 2,
    title: "Get the milk"
    status: "active"
  }
]


app.use(cors())
app.use express.static(__dirname + '/public')
app.use bodyParser.json()

app.get '/api/todos', (req, res) ->
  res.send {todos}

app.get '/api/todos/:id', (req, res) ->
  id = parseInt(req.params.id)
  todo = _.first todos.filter (todo) -> todo.id == id
  res.send todo

app.listen 5000
