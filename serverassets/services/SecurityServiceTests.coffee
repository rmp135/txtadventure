chai = require "chai"
chai.should()

securityService = require '../../server/services/securityService.js'

module.exports = describe 'SecurityService', ->
  it 'should salt a username and password combination', (done) ->
    securityService.generateHash 'password'
    .then (hash) ->
      hash.should.exist
      done()

  it 'should return true when a password is authenticated', (done) ->
    password = 'password'
    securityService.generateHash password
    .then (hash) ->
      securityService.isAuthed password, hash
      .then (res) ->
        res.should.be.true
        done()
        
  it 'should return false when a password is not authenticated', (done) ->
    password = 'password'
    securityService.generateHash password
    .then (hash) ->
      securityService.isAuthed 'notpassword', hash
    .then (res) ->
      res.should.be.false
      done()
