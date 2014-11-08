var todoApp = angular.module('todoApp', [])

todoApp.factory('resourceService', function($http, $q) {
  return {
    // This invokes a transition in a resource
    invoke: function(resource, rel, data) {
      // If the items are embedded, return those items
      // No need to traverse links
      if (!resource.transitions[rel]) {
        if (!resource.embedded[rel]) return;
        return resource.embedded[rel];
      }

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
    if (todo.transitions.markComplete) {
      return 'active';
    } else {
      return 'completed';
    }
  }

  setTodosFromResponse = function(resource) {
    $scope.setTodos(resource[0])
  }

  $scope.setTodos = function(resource) {
    $scope.root = resource;
    $scope.todos = resourceService.invoke(resource, 'todo');
  }

  $scope.createTodo = function() {
    resourceService
      .invoke($scope.root, 'create', $scope.createForm)
      .then(setTodosFromResponse);
    $scope.createForm = {}
  };

  $scope.deleteTodo = function(todo) {
    resourceService
      .invoke(todo, 'delete')
      .then(setTodosFromResponse);
  };

  $scope.completeTodo = function(todo) {
    resourceService
      .invoke(todo, 'markComplete')
      .then(setTodosFromResponse);
  };

  $scope.activateTodo = function(todo) {
    resourceService
      .invoke(todo, 'markActive')
      .then(setTodosFromResponse);
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
