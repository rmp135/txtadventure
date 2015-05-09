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
    
.controller 'MessagesDetailController', ($scope, $stateParams, $timeout, messageService, phoneService, conversation)->
    console.log 'messagedetail initialised'
    scrollToTop = ->
        $timeout ->
            messageThread = document.getElementById('conversationlist');
            messageThread.scrollTop = messageThread.scrollHeight;
        ,0
        
    do scrollToTop
    
    $scope.conversation = conversation

    $scope.contact =
        number:$stateParams.Contact

    $('#msgbox').keydown (key) ->
        if key.which is 13 then $scope.sendmsg($scope.newmessage)
        return

    $scope.sendmsg = (msg) ->
        return if msg is ""
        $scope.newmessage = ""
        $scope.conversation.push {message:msg, From:id:phoneService.id, To:id:$stateParams.id}
        messageService.sendMessageToUser $stateParams.id, msg
        do scrollToTop

    return

.controller 'TerminalController', ($timeout, $scope) ->
  console.log 'terminal initialised'
  $scope.enabled = false
  $scope.flashing = false
  $scope.history = []
  $scope.commandLine = ''
  #$scope.accessor = {}
  $timeout ->
    if $scope.accessor?
      $scope.accessor.blink 'Welcome agent.', -> $scope.enabled = true
  , 0
  $scope.test = (m) ->
    m.toUpperCase()
  $scope.execute = (msg) ->
    $scope.accessor.echo '> ' + msg
    
    $scope.flashing = false
    switch msg.toLowerCase()
      when '', null
        $scope.flashing = true
      when 'scramble', 's'
        $scope.accessor.scramble "SCRAMBLED!", {}, -> $scope.flashing = true
      when 'generate', 'g'
        generateNumber = ->
          tail = Math.round(Math.random()*Math.pow(10,8))
          '077' + if tail > Math.pow(10,7) then tail else '0'+tail
        
        $scope.accessor.blink 'Generating new number...', ->
          $scope.accessor.scramble generateNumber(), {digits:'0123456789', cycles:5}, -> $scope.flashing= true
      when 'rescramble', 'r'
        $scope.accessor.rescramble 'RESCRAMBLED!', {}, -> $scope.flashing = true
        #$scope.history.push 'Enter phone number.'
      else
        $scope.accessor.blink 'Command not recognised.', -> $scope.flashing = true
        #$scope.$apply()
    #$timeout ->
      #viewport = $('#terminal-viewport')[0];
      #viewport.scrollTop = viewport.scrollHeight;
    #,0


#echo 'Welcome agent.',
  #->
    #line = document.createElement('pre')
    #output.appendChild line
    #scramble
    #rescramble line, 'ENCRYPTED TEXT!',{},->
      #$scope.enabled = true 
    #rescramble line, 'abcdefghijklmnopqrstuvwxyz'.toUpperCase(), 10, 50, 'LAJFISLAJW', 'SCRAMBLED!' ->
      #scramble '07754757318', '0123456789', 10, 50, line, ->
