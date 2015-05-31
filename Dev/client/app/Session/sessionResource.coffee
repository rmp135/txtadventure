angular.module 'Session'
.factory 'Session', ($resource) ->
  $resource '/api/session/:token'