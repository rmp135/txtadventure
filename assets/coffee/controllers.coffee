angular.module 'app.controllers', ['app.services', 'app.directives']
.controller 'LoginController', ->
    console.log 'login initialised'
    return
    
.controller 'DeviceController', ->
    console.log 'device initialised'
    return
    
.controller 'SpringboardController', ->
    console.log 'springboard initialised'
    return
    
.controller 'PhoneController', ->
    console.log 'phone initialised'
    #Hide back button on first load.
    $('#backbtn').children().css('display','none')
    addPhoneEventHandler = (el) ->
        el.addEventListener('mousedown', (e) ->
            numpad = $('#numberoutput')[0]
            numpad.innerHTML = numpad.innerHTML + e.target.innerHTML
            $('#backbtn').children().css('display','')
            console.log e.target.id
            )
        return
    
    addPhoneEventHandler x for x in $('.numkey')
    
    document.getElementById('backbtn').children[0].addEventListener('mousedown', ->
        $('#numberoutput')[0].innerHTML = ""
        $('#backbtn').children().css('display','none')
        return
    )
    return
    
.controller 'ContactsController', ->
    console.log 'contacts initialised'
    return
    
.controller 'MessagesListController', ($scope, messageService, Conversation)->
    console.log 'messageslist initialised'
    $scope.conversations = messageService.getConversationHeaders()
    $scope.conversations.$promise
    .then (m) ->
        console.log m
    return
    
.controller 'MessagesDetailController', ($scope, $stateParams, messageService, phoneService)->
    console.log 'messagedetail initialised'
    $scope.conversation = messageService.getMessagesInConversation($stateParams.id)
    $scope.contact =
        number:$stateParams.Contact
    $('#msgbox').keydown (key) ->
        if key.which is 13 then $scope.sendmsg($scope.newmessage)
        return

    $scope.sendmsg = (msg) ->
        return if msg is ""
        $('#msgbox').val = ""
        $scope.newmessage = ""
        console.log msg
        $scope.conversation.push {message:msg, From:id:phoneService.id, To:id:$stateParams.id}
        messageService.sendMessageToUser $stateParams.id, msg
    return