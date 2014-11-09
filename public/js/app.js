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
  var rootUrl = '/api'

  // Set some initial data
  $scope.todos = [];
  $scope.createForm = {};

  setTodosFromResponse = function(resource) {
    return $scope.setTodos(resource[0]);
  }

  getTodoList = function(resource) {
    return resourceService.invoke(resource[0], 'list')
      .then(setTodosFromResponse)
  }

  $scope.setTodos = function(resource) {
    $scope.root = resource;
    $scope.todos = resourceService.invoke(resource, 'todo');
  }

  $scope.createTodo = function() {
    resourceService
      .invoke($scope.root, 'create', $scope.createForm)
      //.then(setTodosFromResponse)
      .then(getTodoList);

    // Reset the create form
    $scope.createForm = {}
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
      canEdit: function(todo) {
        return !!todo.transitions.edit;
      },
      canActivate: function(todo) {
        return !!todo.transitions.markActive;
      },
      canDelete: function(todo) {
        return !!todo.transitions.delete;
      }
    }
  }

  // Load initial todos
  $http.get(rootUrl)
    .then(function(resource) {
      return resourceService.invoke(resource.data, 'todos')
    })
    .then(function(resource) {
      $scope.defineConditions();
      return $scope.setTodos(resource[0]);
    })
});

todoApp.directive('todoItem', function() {
  return {
    templateUrl: 'todo-item.html',
    scope: {
      todo: "=",
      cond: "="
    },
    controller: function($scope, resourceService) {
      $scope.editing = false;
      $scope.editForm = { title: $scope.todo.attributes.title };

      $scope.getState = function() {
        if ($scope.todo.transitions.markComplete) return 'active';
        return 'completed';
      }

      $scope.editTodo = function() {
        resourceService
          .invoke($scope.todo, 'edit', $scope.editForm)
          .then(function(resource) {
            $scope.todo = angular.extend($scope.todo, resource[0]);
            $scope.editForm = { title: $scope.todo.attributes.title }
            $scope.editing = false;
          });
      }

      $scope.deleteTodo = function() {
        resourceService
          .invoke($scope.todo, 'delete')
          .then(getTodoList);
      };

      $scope.completeTodo = function() {
        resourceService
          .invoke($scope.todo, 'markComplete')
          .then(function(resource) {
            $scope.todo = angular.extend($scope.todo, resource[0]);
          });
      };

      $scope.activateTodo = function() {
        resourceService
          .invoke($scope.todo, 'markActive')
          .then(function(resource) {
            $scope.todo = angular.extend($scope.todo, resource[0]);
          });
      };
    },
    link: function(scope, element, attrs, ctrl) {
      element.find('h2').on('click', function(e) {
        e.stopPropagation();

        if (scope.cond.canEdit(scope.todo)) {
          scope.$apply(function() { scope.editing = true; });
          element.find('.edit-box').focus();

          function removeFocus(e) {
            scope.$apply(function() { scope.editing = false; });
            angular.element(document).off('click', removeFocus);
          }

          angular.element(document).on('click', removeFocus);

          element.find('form').on('click', function(e) {
            e.stopPropagation();
          });
        }
      });
    }
  }
});
