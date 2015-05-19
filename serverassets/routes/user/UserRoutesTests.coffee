assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"

testHelper = require 'testHelper'
schemas = require 'schemas'
sqlService = require 'sqlService'
securityService = require 'securityService'

root = "http://localhost:#{process.env.PORT}/api"

module.exports = describe 'UserRoutesTests', ->
  describe 'Creating', ->
    it 'should 409 if the number already exists', (done) ->
      number = testHelper.genNumber()
      sqlService.accounts.createNewAccount number, 'password'
      .then ->
        request root
        .post '/user'
        .send number:number, pin:'password'
        .endAsync()
      .then (res) ->
        res.status.should.equal 409
        done()
      
    it 'should not allow adding a user with no number', (done) ->
      request root
      .post '/user'
      .send pin:"223"
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
        
    it 'should not allow adding a user with a number of the wrong length', (done) ->
      request root
      .post '/user'
      .send number:"09",pin:"0293"
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
        
    it 'should not allow adding a user with no pin', (done) ->
      request root
      .post '/user'
      .send number:"09982736273"
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
        
    it 'should not allow adding a user with a too short pin', (done) ->
      request root
      .post '/user'
      .send number:"09876782736", pin:"98"
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
    
    it 'should allow adding a user correctly', (done) ->
      request root
      .post '/user'
      .send number:"07782738273", pin:"09334"
      .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
        done()
  
  describe 'Reading', ->
    it 'should return a user by id if the user is authorised', (done) ->
      testHelper.login()
      .then (loginDetails) ->
        {user, session} = loginDetails
        request root
        .get "/user/#{user.id}"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
        done()
    
    it 'should 403 returning a user when not authorised', (done) ->
      testHelper.login()
      .then (loginDetails) ->
        {user, session} = loginDetails
        request root
        .get "/user/1"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
          
    it 'should 403 returning a user when no cookie is set', (done) ->
      request root
      .get "/user/1"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
        
    
  describe.skip 'Updating', ->
    it 'should 404 updating a user that does not exist', (done) ->
      done()
