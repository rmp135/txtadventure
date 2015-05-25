angular.module 'MessageDetail'    
.controller 'MessageDetailController', ($scope, $stateParams, $timeout, messageService, userService, conversation, contact)->
    console.log 'messagedetail initialised'
    $scope.conversation = conversation
    $scope.contact = contact
    scrollToTop = ->
        $timeout ->
            messageThread = $('#messages');
            messageThread.scrollTop(messageThread[0].scrollHeight);
        ,0
        
    scrollToTop()
    
    # conversation and contact is pulled from the app resolve function before the page loads.

    $('#msgbox').keydown (key) ->
        if key.which is 13 then $scope.sendmsg($scope.newmessage)

    $scope.sendmsg = (msg) ->
        return if msg is ""
        $scope.newmessage = ""
        $scope.conversation.push {message:msg, from:userService.currentUser.number}
        messageService.sendMessageToContact $stateParams.id, msg
        scrollToTop()