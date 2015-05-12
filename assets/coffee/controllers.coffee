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
            )
        return
    
    addPhoneEventHandler x for x in $('.numkey')
    
    $('#backbtn').children()[0].addEventListener('mousedown', ->
        $('#numberoutput')[0].innerHTML = ""
        $('#backbtn').children().css('display','none')
        return
    )
    return
    
.controller 'ContactsController', ($scope, contactService, contacts) ->
  $scope.contacts = contacts
  return
  
.controller 'MessagesListController', ($scope, messageService, Conversation)->
    console.log 'messageslist initialised'
    $scope.conversations = messageService.getConversationHeaders()
    $scope.conversations.$promise
    .then (m) ->
        console.log m
    return
    
.controller 'MessagesDetailController', ($scope, $stateParams, $timeout, messageService, phoneService, conversation, contact)->
    console.log 'messagedetail initialised'
    $scope.conversation = conversation
    $scope.contact = contact
    scrollToTop = ->
        $timeout ->
            messageThread = $('#conversationlist');
            messageThread.scrollTop(messageThread[0].scrollHeight);
        ,0
        
    scrollToTop()
    
    # conversation and contact is pulled from the app resolve function before the page loads.

    $('#msgbox').keydown (key) ->
        if key.which is 13 then $scope.sendmsg($scope.newmessage)
        return

    $scope.sendmsg = (msg) ->
        return if msg is ""
        $scope.newmessage = ""
        $scope.conversation.push {message:msg, From:id:phoneService.currentUser.id, To:id:$stateParams.id}
        messageService.sendMessageToUser $stateParams.id, msg
        scrollToTop()

    return

.controller 'TerminalController', ($timeout, $scope, $state) ->
  console.log 'terminal initialised'
  $scope.enabled = false
  $scope.flashing = false
  $scope.history = []
  $scope.commandLine = ''
  $scope.secret = false
  blink = null
  
  echo = (msg) -> $scope.accessor.echo "> #{msg}"
  
  state = 'main'
  machine = new StateMachine()
  .state 'home',
    "l|login": ->
      machine.transitionToState 'login'
    "s|scramble": ->
      $scope.flashing=false
      $scope.accessor.scramble "SCRAMBLED!", {}, ->
        $scope.flashing=true
    "r|rescramble": ->
      $scope.accessor.rescramble "RESCRAMBLED"
    "j|join|g|generate": ->
      machine.transitionToState "join"
    "t|test": ->
      console.log "put test stuff here!"
    otherwise: ->
      $scope.accessor.blink "Command not recognised."
  ,
    onEnter: ->
      $scope.accessor.blink "Enter your command."
    preAction: ->
      echo $scope.commandLine
  .state "join", 
    otherwise: ->
      echo "*".repeat $scope.commandLine.length
      $scope.enabled = false
      $scope.accessor.echoMultiple ["Accessing secure network...", "Logging in..."],{delay:500}, -> $timeout (-> $state.go('springboard')), 1000
  ,
    onEnter: ->
      $scope.enabled = false
      generateNumber = ->
            tail = Math.round(Math.random()*Math.pow(10,8))
            '077' + if tail > Math.pow(10,7) then tail else '0'+tail
      blink "Generating new number...", ->
        $scope.accessor.scramble generateNumber(), {digits:"0123456789"}, ->
          blink "Enter a new PIN.", ->
            $scope.flashing = true
            $scope.enabled = true
            $scope.secret = true
        
  .state 'login', 
    "q|quit": ->
      machine.transitionToState 'home'
    otherwise: ->
      machine.transitionToState "login.password"
  ,
    onEnter: ->
      blink "Enter your phone number. (q) to go back"
  .state 'login.password', {},
    onEnter: ->
      $scope.flashing = false
      blink "Enter PIN for this number.", ->
        $scope.flashing = true
    
  
  $timeout ->
    if $scope.accessor?
      blink = $scope.accessor.blink
      $scope.accessor.blink 'Welcome agent.', ->
        $scope.enabled = true
        machine.transitionToState 'home'
  , 0
  
  $scope.execute = (msg) ->
    #$scope.commandLine = ''
    msg = msg.toLowerCase()
    machine.performAction msg
    $scope.commandLine = ''
