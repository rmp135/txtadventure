angular.module 'MessageList'
.controller 'MessageListController', ($scope, messageService)->
    console.log 'messageslist initialised'
    $scope.conversations = messageService.getMessageHeaders()
    return
