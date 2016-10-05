angular.module 'User'
.factory 'userService', ($http, User) ->
  userService = {}
  
  userService.currentUser = null
  userService.login = (number, pin) ->
    $http.post "/api/login", {number, pin}
    .then (res) ->
      userService.currentUser = id:res.data.id, number:res.data.number
      res.data
  userService.createUser = (number, pin) ->
    User.save {number, pin}
    .$promise
    .then (res) ->
      id:res.id, number:res.number

  return userService