internalModules = [
  'Contact'
  'ContactList'
  'Device'
  'Message'
  'MessageDetail'
  'MessageList'
  'Phone'
  'Springboard'
  'Terminal'
  'User'
  'Session'
  'Settings'
]

externalModules = [
  'ui.router'
  'ngAnimate'
  'ngResource'
  'ngCookies'
]

angular.module module, [] for module in internalModules

angular.module 'app', externalModules.concat internalModules
.config ($resourceProvider) ->
    $resourceProvider.defaults.stripTrailingSlashes = false
.config ($urlRouterProvider, $stateProvider) ->
    $urlRouterProvider.otherwise 'springboard'
    $stateProvider
    .state 'springboard',
      url: '/springboard'
      controller: 'SpringboardController'
      templateUrl:'/partials/springboardPartial.html'
      resolve: 
        session: (sessionService) ->
          sessionService.resolveSession()
    .state 'phone',
      url: '/phone'
      controller: 'PhoneController'
      templateUrl: '/partials/phonePartial.html'
      params:
        number:{}
      resolve:
        session: (sessionService) ->
          sessionService.resolveSession()
    .state 'settings',
      url: '/settings'
      controller: 'SettingsController'
      templateUrl: '/partials/settingsPartial.html'
      resolve:
        session: (sessionService) ->
          sessionService.resolveSession()
    .state 'contactlist',
      url: '/contacts'
      controller: 'ContactListController'
      templateUrl: '/partials/contactListPartial.html'
      resolve:
        session: (sessionService) ->
          sessionService.resolveSession()
        contacts: (session, contactService, userService) ->
          contactService.getContacts userService.currentUser.id
    .state 'messagelist',
      url: '/messages/'
      controller: 'MessageListController'
      templateUrl: '/partials/messageListPartial.html'
      resolve:
        session: (sessionService) ->
          sessionService.resolveSession()
    .state 'messagedetail',
      url: '/messages/:id'
      controller: 'MessageDetailController'
      templateUrl: 'partials/messageDetailPartial.html'
      resolve:
        session: (sessionService) ->
          sessionService.resolveSession()
        contact: (session, $stateParams, userService, Contact) ->
          Contact.get id:userService.currentUser.id, contactId:$stateParams.id
        conversation: (contact, $stateParams, messageService) ->
          messageService.getMessagesInMessage($stateParams.id).$promise
    .state 'terminal',
      url: '/terminal'
      controller: 'TerminalController'
      templateUrl: '/partials/terminalPartial.html'
.run ($rootScope, $state, $stateParams, sessionService, userService) ->

  $rootScope.$on "$stateChangeError", (event, toState, toParams, fromState, fromParams) ->
    event.preventDefault()
    $state.go 'terminal'

  # $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
    # if fromState.name is "" and toState.name isnt 'springboard' and toState.name isnt 'terminal'
    #   event.preventDefault()
    #   $state.go 'springboard'

    # else if not sessionService.currentSession and toState.name isnt 'terminal'
    #   event.preventDefault()
    #   $state.go 'terminal'
  


  # if sessionService.currentSession and not userService.currentUser
  #   sessionService.getSessionDetails sessionService.currentSession
  #   .then (user) ->
  #     userService.currentUser = user ? $state.go 'terminal'

  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams

setInterval -> 
  if document.getElementById 'time'
    date = new Date()
    padTime = (time) -> 
        if time > 9 then time else "0"+time
    document.getElementById('time').innerText = padTime(date.getHours()) + " : " + padTime(date.getMinutes())
,120
