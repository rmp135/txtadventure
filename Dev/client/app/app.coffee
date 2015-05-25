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
]

externalModules = [
  'ui.router'
  'ngAnimate'
  'ngResource'
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
    .state 'phone',
      url: '/phone'
      controller: 'PhoneController'
      templateUrl: '/partials/phonePartial.html'
      params:
        number:{}
    .state 'contactlist',
      url: '/contacts'
      controller: 'ContactListController'
      templateUrl: '/partials/contactListPartial.html'
      resolve:
        contacts: (contactService, userService) ->
          contactService.getContacts userService.currentUser.id
    .state 'messagelist',
      url: '/messages/'
      controller: 'MessageListController'
      templateUrl: '/partials/messageListPartial.html'
    .state 'messagedetail',
      url: '/messages/:id'
      controller: 'MessageDetailController'
      templateUrl: 'partials/messageDetailPartial.html'
      resolve:
        conversation: ($stateParams, messageService) ->
          messageService.getMessagesInMessage($stateParams.id).$promise
        contact: ($stateParams, userService, Contact) ->
          Contact.get id:userService.currentUser.id, contactId:$stateParams.id
    .state 'terminal',
      url: '/terminal'
      controller: 'TerminalController'
      templateUrl: '/partials/terminalPartial.html'
.run ($rootScope, $state, $stateParams) ->
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams

setInterval -> 
    date = new Date()
    padTime = (time) -> 
        if time > 9 then time else "0"+time
    document.getElementById('time').innerText = padTime(date.getHours()) + " : " + padTime(date.getMinutes())
,120
