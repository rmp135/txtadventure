angular.module 'app', ['ui.router', 'ngAnimate', 'app.controllers', 'app.filters']
.config ($resourceProvider) ->
    $resourceProvider.defaults.stripTrailingSlashes = false
    return
.config ($urlRouterProvider, $stateProvider) ->
    $urlRouterProvider.otherwise 'springboard'
    $stateProvider
    .state 'login',
      url: '/login'
      controller: 'LoginController'
      templateUrl: '/views/login.html'
    .state 'springboard',
      url: '/springboard'
      controller: 'SpringboardController'
      templateUrl:'/views/springboard.html'
    .state 'phone',
      url: '/phone'
      controller: 'PhoneController'
      templateUrl: '/views/phone.html'
      params:
        number:{}
    .state 'contacts',
      url: '/contacts'
      controller: 'ContactsController'
      templateUrl: '/views/contacts.html'
      resolve:
        contacts: (contactService, phoneService) ->
          contactService.getContacts phoneService.currentUser.id
    .state 'messageslist',
      url: '/messages/'
      controller: 'MessagesListController'
      templateUrl: '/views/messageslist.html'
    .state 'messagesdetail',
      url: '/messages/:id'
      controller: 'MessagesDetailController'
      templateUrl: 'views/messagedetail.html'
      resolve:
        conversation: ($stateParams, messageService) ->
          messageService.getMessagesInConversation($stateParams.id).$promise
        contact: ($stateParams, phoneService, Contact) ->
          Contact.get id:phoneService.currentUser.id, contactId:$stateParams.id
    .state 'terminal',
      url: '/terminal'
      controller: 'TerminalController'
      templateUrl: '/views/terminal.html'
      
    return
.run ($rootScope, $state, $stateParams) ->
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
    return

setInterval -> 
    date = new Date()
    padTime = (time) -> 
        if time > 9 then time else "0"+time
    document.getElementById('time').innerText = padTime(date.getHours()) + " : " + padTime(date.getMinutes())
    return
,120
