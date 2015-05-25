angular.module 'Contact'
.factory 'Contact', ($resource) ->
  $resource '/api/user/:id/contacts/:contactId'