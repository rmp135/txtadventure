assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"
schemas = require('../../../server/schemas.js')

sqlService = require '../../../server/services/sqlService.js'
securityService = require '../../../server/services/securityService.js'

root = "http://localhost:#{process.env.PORT}/api"

genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail


module.exports = describe 'UserRoutesTests', ->
  describe 'Creating', ->
    it 'should not allow adding a user with no number', (done) ->
      request root
      .post '/user'
      .send pin:"223"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 400
        done()
        
    it 'should not allow adding a user with a number of the wrong length', (done) ->
      request root
      .post '/user'
      .send number:"09",pin:"0293"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 400
        done()
        
    it 'should not allow adding a user with no pin', (done) ->
      request root
      .post '/user'
      .send number:"09982736273"
      .end (err, res) ->
        throw err if err
        res.status.should.equal(400)
        done()
        
    it 'should not allow adding a user with a too short pin', (done) ->
      request root
      .post '/user'
      .send number:"09876782736", pin:"98"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 400
        done()
    
    it 'should allow adding a user correctly', (done) ->
      request root
      .post '/user'
      .send number:"07782738273", pin:"09334"
      .end (err, res) ->
        throw err if err
        expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
        done()
  
  describe 'Reading', ->
    it 'should return a user by id', (done) ->
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user) ->
        request root
        .get "/user/#{user.id}"
        .end (err, res) ->
          throw err if err
          expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
          done()
    
    it 'should 404 returning a user that does not exist', (done) ->
      request root
      .get "/user/222/contacts"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()
    
  describe.skip 'Updating', ->
    it 'should 404 updating a user that does not exist', (done) ->
      done()
