angular.module 'User'
.factory 'User', ($resource) ->
  $resource '/api/user/:id'