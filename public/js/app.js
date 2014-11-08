var todoApp = angular.module('todoApp', [])

todoApp.run(function($http) {
  $http.defaults.headers.common.Accept = 'application/vnd.smizell.hypermedia+json'
});

todoApp.factory('resourceService', function($http, $q) {
  return {
    // This invokes a transition in a resource
    invoke: function(resource, rel, data) {
      // If the items are embedded, return those items
      // No need to traverse links if we already have what we want
      if (!resource.transitions[rel]) {
        if (!resource.embedded[rel]) return;
        return resource.embedded[rel];
      }

      // We let the message provide the URL and method for us
      // when building a list of promises
      var promises = resource.transitions[rel].map(function(todo) {
        var method = todo.method || 'get';
        return $http[method.toLowerCase()](todo.href, data)
      });

      return $q.all(promises).then(function(resources) {
        return resources.map(function(resource) {
          return resource.data;
        })
      });
    }
  }
});

todoApp.controller('mainController', function($scope, $http, resourceService) {
  // The only URL my app knows, the "front door"
  var rootUrl = '/todos'

  // Set some initial data
  $scope.todos = [];
  $scope.createForm = {};

  // Load initial todos
  $http.get(rootUrl)
    .success(function(resource) {
      $scope.defineConditions();
      $scope.setTodos(resource);
    })
    .error(function(data) { console.log('Error: ' + data); });

  // The state of a todo based on affordances
  $scope.getState = function(todo) {
    if (todo.transitions.markComplete) return 'active';
    return 'completed';
  }

  $scope.setTodos = function(resource) {
    $scope.root = resource;
    $scope.todos = resourceService.invoke(resource, 'todo');
  }

  setTodosFromResponse = function(resource) {
    $scope.root = resource[0];
    $scope.todos = resourceService.invoke(resource[0], 'todo');
  }

  getTodoList = function(resource) {
    resourceService.invoke(resource[0], 'list')
      .then(setTodosFromResponse)
  }

  $scope.createTodo = function() {
    resourceService
      .invoke($scope.root, 'create', $scope.createForm)
      //.then(setTodosFromResponse)
      .then(getTodoList);

    // Reset the create form
    $scope.createForm = {}
  };

  $scope.deleteTodo = function(todo) {
    resourceService
      .invoke(todo, 'delete')
      .then(getTodoList);
  };

  $scope.completeTodo = function(todo) {
    resourceService
      .invoke(todo, 'markComplete')
      .then(getTodoList);
  };

  $scope.activateTodo = function(todo) {
    resourceService
      .invoke(todo, 'markActive')
      .then(getTodoList);
  };

  // Conditions based on affordances
  $scope.defineConditions = function() {
    $scope.cond = {
      canCreate: function() {
        return !!$scope.root.transitions.create;
      },
      canComplete: function(todo) {
        return !!todo.transitions.markComplete;
      },
      canActivate: function(todo) {
        return !!todo.transitions.markActive;
      },
      canDelete: function(todo) {
        return !!todo.transitions.delete;
      }
    }
  }
});
