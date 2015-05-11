angular.module 'app', ['ui.router', 'ngAnimate', 'app.controllers', 'app.filters']
#.config ($resourceProvider) ->
    #$resourceProvider.defaults.stripTrailingSlashes = false
    #return
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
    .state 'contacts',
      url: '/contacts'
      controller: 'ContactsController'
      templateUrl: '/views/contacts.html'
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
          return messageService.getMessagesInConversation($stateParams.id).$promise
      params:
        Contact:{}
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
