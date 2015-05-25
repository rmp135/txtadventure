angular.module 'MessageDetail'
.directive 'message', (userService) ->
    {
        restrict:'A'
        scope:{message:"="}
        link: (scope, el, att) ->
            if userService.currentUser.number is scope.message.from
                el.addClass 'message-right'
            else
                el.addClass 'message-left'
    }
