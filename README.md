# Hypermedia Todo Example

This is an example of some neat tricks you can do with a hypermedia API and a
hypermedia-enabled client.

## Examples

These examples are very manual, but the purpose is to see what is changed in the code to make these examples work.

### Embed transitions rather than link to them

One trick you can do is to embed transitions instead of linking to them it the client knows how to handle this. This comes in handy in situations where the client may always request a bunch of links, so instead of linking to them, they can be included in a message.

To try this out:

1. Go to the `lib/resources.coffee` file
1. Find the `list` method for the `TodosResource`
1. Comment the lines that create the `todo` links
1. Uncomment the lines that embed the todos

You can see the responses change, but the client should work just the same.

### Build UI to rely on affordances

The client UI is set up to display only the affordances that the API provides in the message. This allows you to change what can be seen by the user at runtime.

To try this out:

1. Go to the `app.coffee` file
1. Find the `authorize` function
1. Set `delete` to false

When this is done, the delete button will not be shown in the UI because the `delete` affordance is not in the message.

### Changing responses

Right now, whenever you create a todo, the client will then invoke the `list` affordance in the message. One thing that *could* be done is to change the response of the create transition to be the actual list.

To try this out:

1. Find the `create` method for the `TodosResource` in the `resources.coffee`
1. Uncomment the line that returns the list
1. Comment the lines that return the todo
1. Go to `public/js/app.js` and find the `$scope.createTodo` function
1. Uncomment the line that uses `setTodoFromResponse`
1. Comment the line that uses `getTodoList`

Everything should work, but now the number of requests should be reduced. This mainly shows the effort it takes to change responses. It is not a normal thing you want to do with a production API.

### Changing URLs

Since the client relies on the server for the URLs, the server could change its URLs and the client will stil work.

To try this out, simply go to the `app.coffee` and find/replace `/todos` with `/something`. The client will still work.

### Changing the server

To take the previous example further, instead of simply changing the URLs, the server could send the client to a completely different server. The client would still work.

There are several ways to show this example. Here's what I'm doing:

1. Copy the enter folder to another location on your system (this will be our secondary location)
1. In the primary `app.coffee`, find the `base` variable and change the port from 3000 to 4000.
1. In the primary `app.coffee `, find the response for `/todos` and uncomment the redirect line and remove the rest of the response
1. In the secondary `app.coffee`, find the `base` variable and change the port from 3000 to 4000. At the end of the file, change the listening port to 4000.

Once complete, make sure both servers are running and have been restarted.

Now go to http://127.0.0.1:3000 and you should see the reponses directing you to the secondary server.
