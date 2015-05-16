angular.module 'app.resources', ['ngResource']
.factory 'User', ($resource) ->
  $resource '/api/user/:id'
.factory 'Contact', ($resource) ->
  $resource '/api/user/:id/contacts'
.factory 'Conversation', ($resource)->
  $resource '/api/user/:userid/messages/:contactId'