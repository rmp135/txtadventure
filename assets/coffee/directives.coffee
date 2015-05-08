angular.module 'app.directives', ['app.services']
.directive 'message', (phoneService)->
    {
        restrict:'A'
        scope:{message:"="}
        link: (scope, el, att) ->
            id = phoneService.id
            if id is scope.message.From.id
                el.addClass 'message-right'
            else
                el.addClass 'message-left'
    }
