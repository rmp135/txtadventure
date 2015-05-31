describe 'SessionService', ->
  sessionService = httpBackend = cookies = null
  beforeEach ->
    module 'Session'
    module 'User'
    module 'ngResource'
    module 'ngCookies'
  
  beforeEach inject (_sessionService_, $httpBackend, $cookies) ->
      sessionService = _sessionService_
      httpBackend = $httpBackend
      cookies = $cookies

  it 'should return the account details if the server returns them', (done) ->
    cookies.put 'session', 'token'
    
    httpBackend
    .expectGET /\/session\/.*/
    .respond
      id:2
      number:"07754757318"
    
    sessionService
    .getSessionDetails "mocktoken"
    .then (user) ->
      expect user
      .toEqual id:2, number:"07754757318"
      done()

    httpBackend.flush()

  it 'should return null if the server does not have the session', (done) ->
    cookies.put 'session', 'token'
    
    httpBackend
    .expectGET /\/session\/.*/
    .respond 404

    sessionService
    .getSessionDetails "mocktoken"
    .then (user) ->
      expect user
      .toBe null
      done()

    httpBackend.flush()
    
  it 'should return the current session token', ->
    cookies.put 'session', 'token'
    expect sessionService.currentSession
    .toEqual 'token'

  it 'should return null if the current session is not set', ->
    console.log cookies.get 'session'
    expect sessionService.currentSession
    .toEqual null

  afterEach ->
    cookies.remove 'session'
    