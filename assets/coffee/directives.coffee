angular.module 'app.directives', ['app.services']
.directive 'message', (phoneService)->
    {
        restrict:'A'
        scope:{message:"="}
        link: (scope, el, att) ->
            number = phoneService.number
            if number is scope.message.User.number
                el.addClass 'message-right'
            else
                el.addClass 'message-left'
    }
