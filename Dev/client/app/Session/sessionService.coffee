angular.module 'Session'
.factory 'sessionService', (Session, userService, $cookies) ->
  sessionService = {}
  Object.defineProperty sessionService, 'currentSession',
  	get: -> $cookies.get('session') ? null
  sessionService.getSessionDetails = ->
    Session.get token:sessionService.currentSession
    .$promise
    .then (res) ->
      id:res.id, number:res.number
    .catch (res) ->
      return null

  return sessionService