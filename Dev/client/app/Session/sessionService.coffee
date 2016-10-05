angular.module 'Session'
.factory 'sessionService', (Session, userService, $cookies, $q) ->
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
  
  sessionService.resolveSession = ->
    console.log 'Route changed, resolving session. '
    return $q (resolve, reject) ->
      if not sessionService.currentSession? then console.log 'No current session. Rejecting.'; return reject()
      if userService.currentUser? then console.log 'User found, using that.'; return resolve()
      console.log 'Fetching session from API.'
      sessionService.getSessionDetails()
      .then (user) ->
        if not user? then return reject()
        console.log "Session found for user #{user}"
        userService.currentUser = user
        resolve()
      .catch ->
        reject()

  return sessionService