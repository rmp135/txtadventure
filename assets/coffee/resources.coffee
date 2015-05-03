angular.module 'app.resources', ['ngResource']
.factory 'Conversation', ($resource)->
    $resource '/api/user/:userid/conversations/:id'