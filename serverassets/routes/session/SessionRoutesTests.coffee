assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"

schemas = require 'schemas'
sqlService = require 'sqlService'

root = "http://localhost:#{process.env.PORT}/api"

genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail

createNewAccount = -> sqlService.accounts.createNewAccount genNumber(), genNumber()

module.exports = describe 'SessionRoutesTests', ->
  describe 'Creating', ->
    it 'should place a session cookie when a valid user logs in', (done) ->
      number = genNumber()
      pin = '999'
      sqlService.accounts.createNewAccount number, pin
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin}
        .end (err, res) ->
          throw err if err
          /^session=.*/.test(res.header['set-cookie']).should.be.true
          res.status.should.equal 200
          done()
    
    it 'should persist the session when a user logs in', (done) ->
      number = genNumber()
      pin = '999'
      sqlService.accounts.createNewAccount number, pin
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin}
        .end (err, res) ->
          throw err if err
          res.status.should.equal 200
          sqlService.sessions.findByUserId user.id
          .then (session) ->
            expect(session).to.exist
            done()
    
    it 'should 403 logging in with incorrect password', (done) ->
      number = genNumber()
      password = '999'
      sqlService.accounts.createNewAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin:'not999' }
        .end (err, res) ->
          throw err if err
          res.status.should.equal 403
          done()
          
    it 'should 403 logging in with incorrect number', (done) ->
      request root
      .post '/login'
      .send {number:"99999999999", pin:"9999"}
      .end (err, res) ->
        throw err if err
        res.status.should.equal 403
        done()

    it 'should not set a cookie logging in with incorrect password', (done) ->
      number = genNumber()
      password = '999'
      sqlService.accounts.createNewAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {number, pin:'not999' }
        .end (err, res) ->
          throw err if err
          /^session=.*/.test(res.header['set-cookie']).should.be.false
          done()

    it 'should not set a cookie logging in with incorrect number', (done) ->
      request root
      .post '/login'
      .send {number:"99999999999", "9999"}
      .end (err, res) ->
        throw err if err
        /^session=.*/.test(res.header['set-cookie']).should.be.false
        done()

    it 'should 400 attempting to log in without a username', (done) ->
      number = genNumber()
      password = '999'
      sqlService.accounts.createNewAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send { pin:password }
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          /^session=.*/.test(res.header['set-cookie']).should.be.false
          done()
    it 'should 400 attempting to log in without a password', (done) ->
      number = genNumber()
      password = '999'
      sqlService.accounts.createNewAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send { number }
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          /^session=.*/.test(res.header['set-cookie']).should.be.false
          done()

    it 'should 400 attempting to log in with no body', (done) ->
      number = genNumber()
      password = '999'
      sqlService.accounts.createNewAccount number, password
      .then (user) ->
        request root
        .post '/login'
        .send {}
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          /^session=.*/.test(res.header['set-cookie']).should.be.false
          done()
          
  describe 'Destroying', ->
    it 'should remove all sessions for a user when logging out', (done) ->
      createNewAccount()
      .then (user) ->
        sqlService.sessions.createSessionForUserId user.id
      .then (session) ->
        request root
        .post '/logout'
        .set 'Cookie', ["session=#{session.token}"]
        .send()
        .end (err, res) ->
          throw err if err
          res.status.should.equal 200
          /^session=;/.test(res.header['set-cookie']).should.be.true
          done()

    it 'should return 200 and remove the cookie when the cookie is invalid', (done) ->
        request root
        .post '/logout'
        .send()
        .set 'Cookie', ["session=notatoken"]
        .end (err, res) ->
          throw err if err
          res.status.should.equal 200
          /^session=;/.test(res.header['set-cookie']).should.be.true
          done()

    it 'should return 200 when no cookie exists', (done) ->
        request root
        .post '/logout'
        .send()
        .end (err, res) ->
          throw err if err
          res.status.should.equal 200
          /^session=;/.test(res.header['set-cookie']).should.be.true
          done()