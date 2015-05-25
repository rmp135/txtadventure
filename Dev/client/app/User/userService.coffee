angular.module 'User'
.factory 'userService', ->
    @currentUser = {id:1, number:"001"}
    return @