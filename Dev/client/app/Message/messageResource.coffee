angular.module 'Message'
.factory 'Message', ($resource)->
  $resource '/api/user/:userid/messages/:contactId'