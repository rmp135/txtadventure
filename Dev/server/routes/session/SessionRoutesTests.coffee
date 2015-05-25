assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"

schemas = testRequire 'schemas.js'
sqlService = testRequire 'services/sqlService.js'

testHelper = localRequire '../tests/testHelper.coffee'

root = "http://localhost:10000/api"

module.exports = describe 'SessionRoutesTests', ->
  describe 'Creating', ->
    it 'should place a session cookie when a valid user logs in', (done) ->
      number = testHelper.genNumber()
      pin = testHelper.genPassword()
      testHelper.createAccount number, pin
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin}
        .endAsync()
      .then (res) ->
        /^session=.*/.test(res.header['set-cookie']).should.be.true
        res.status.should.equal 200
        done()
    
    it 'should persist the session when a user logs in', (done) ->
      number = testHelper.genNumber()
      pin = '999'
      testHelper.createAccount number, pin
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin}
        .endAsync()
        .then (res) ->
          res.status.should.equal 200
          sqlService.sessions.findByUserId user.id
        .then (session) ->
          expect(session).to.exist
          done()
    
    it 'should 403 logging in with incorrect password', (done) ->
      number = testHelper.genNumber()
      password = '999'
      testHelper.createAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin:'not999' }
        .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
          
    it 'should 403 logging in with incorrect number', (done) ->
      request root
      .post '/login'
      .send {number:"99999999999", pin:"9999"}
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should not set a cookie logging in with incorrect password', (done) ->
      number = testHelper.genNumber()
      password = '999'
      testHelper.createAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin:'not999' }
        .endAsync()
      .then (res) ->
        /^session=.*/.test(res.header['set-cookie']).should.be.false
        done()

    it 'should not set a cookie logging in with incorrect number', (done) ->
      request root
      .post '/login'
      .send {number:"99999999999", "9999"}
      .endAsync()
      .then (res) ->
        /^session=.*/.test(res.header['set-cookie']).should.be.false
        done()

    it 'should 400 attempting to log in without a username', (done) ->
      number = testHelper.genNumber()
      password = '999'
      testHelper.createAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send { pin:password }
        .endAsync()
        .then (res) ->
          res.status.should.equal 400
          /^session=.*/.test(res.header['set-cookie']).should.be.false
          done()

    it 'should 400 attempting to log in without a password', (done) ->
      number = testHelper.genNumber()
      password = '999'
      testHelper.createAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send { number }
        .endAsync()
      .then (res) ->
        res.status.should.equal 400
        /^session=.*/.test(res.header['set-cookie']).should.be.false
        done()

    it 'should 400 attempting to log in with no body', (done) ->
      number = testHelper.genNumber()
      password = '999'
      testHelper.createAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {}
        .endAsync()
      .then (res) ->
        res.status.should.equal 400
        /^session=.*/.test(res.header['set-cookie']).should.be.false
        done()
          
  describe 'Destroying', ->
    it 'should remove all sessions for a user when logging out', (done) ->
      testHelper.createAccount()
      .then (user) ->
        sqlService.sessions.createSessionForUserId user.id
      .then (session) ->
        request root
        .post '/logout'
        .set 'Cookie', ["session=#{session.token}"]
        .send()
        .endAsync()
      .then (res) ->
        res.status.should.equal 200
        /^session=;/.test(res.header['set-cookie']).should.be.true
        done()

    it 'should return 200 and remove the cookie when the cookie is invalid', (done) ->
        request root
        .post '/logout'
        .send()
        .set 'Cookie', ["session=notatoken"]
        .endAsync()
        .then (res) ->
          res.status.should.equal 200
          /^session=;/.test(res.header['set-cookie']).should.be.true
          done()

    it 'should return 200 when no cookie exists', (done) ->
        request root
        .post '/logout'
        .send()
        .endAsync()
        .then (res) ->
          res.status.should.equal 200
          /^session=;/.test(res.header['set-cookie']).should.be.true
          done()