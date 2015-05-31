describe 'UserService', ->
  userService = httpBackend = null
  beforeEach module 'User'
  beforeEach module 'ngResource'
  
  beforeEach inject (_userService_, $httpBackend) ->
      userService = _userService_
      httpBackend = $httpBackend

  it 'should not set the account information if a 403 is returned', (done) ->
    httpBackend
    .expectPOST '/api/login'
    .respond 403
    
    userService
    .login "07754757318", "password"
    .catch (res) ->
      expect res
      .toExist
      expect userService.currentUser
      .toBe null
      done()
    
    httpBackend.flush()

  it 'should set the current user if the server returns 200', (done) ->
    httpBackend
    .expectPOST '/api/login', {number:"07754757318", pin:"password"}
    .respond
      id:2
      number:"07754757318"

    userService
    .login "07754757318", "password"
    .then (res) ->
      expect res
      .toEqual id:2, number:"07754757318"
      
      expect userService.currentUser
      .toEqual id:2, number:"07754757318"
      
      done()

    httpBackend.flush()
  
  it 'should create a new user and return the user details', (done) ->
    httpBackend
    .expectPOST '/api/user', {number:"07754757318", pin:"password"}
    .respond
      id:2
      number:"07754757318"

    userService
    .createUser "07754757318", "password"
    .then (res) ->
      expect res
      .toEqual id:2, number:"07754757318"
      
      done()

    httpBackend.flush()
    
  it 'should throw if the user was not created', (done) ->
    httpBackend
    .expectPOST '/api/user'
    .respond 403

    userService
    .createUser "07754757318", "password"
    .catch ->
      done()

    httpBackend.flush()
    