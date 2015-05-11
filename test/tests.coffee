assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
debug = require("debug") "test"
request = require "supertest"
Joi = require "joi"
express = require 'express'
server = require('http').createServer(require '../app')
schemas = require('../server/schemas.js')

rewire = require "rewire"
context = require('../server/models')
sqlService = require '../server/services/sqlService.js'

before (done) ->
  context.createContext({storage:'test',logging:true})
  context.recreate force:true
  .then ->
    context.loadFixtures 'fixtures.sql'
  .then ->
    done()

describe 'api', ->
  before  ->
    server.listen(process.env.PORT)
  after ->
    server.close()
  root = "http://localhost:#{process.env.PORT}/api"
  describe 'Users', ->
    userSchema = 
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
    

    it 'should return a user by id', (done) ->
      sqlService.accounts.createNewAccount '000','pass'
      .then (user) ->
        request root
        .get "/user/#{user.id}"
        .end (err, res) ->
          throw err if err
          expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
          done()

    it 'should 404 returning a user that does not exist', (done) ->
      request root
      .get '/user/222'
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()

    it.skip 'should 404 updating a user that does not exist', (done) ->
      done()

describe 'sqlService', ->
  describe 'accounts', ->

    it 'should create a new account', (done) ->
      sqlService.accounts.createNewAccount '000', 'pass'
      .then ->
        sqlService.accounts.findByNumber '000'
        .then (user) ->
          expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
          #user.number.should.equal '000'
          done()

    it 'should not find an account that does not exist', (done) ->
      sqlService.accounts.findByNumber '020'
      .then (user) ->
        expect(user).to.be.null
        done()

            
    it 'should find an account that does exist', (done) ->
      sqlService.accounts.findByNumber '001'
      .then (user) ->
        expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
        user.id.should.equal 1
        user.number.should.equal '001'
        done()
  
  describe 'messaging', ->
    it 'should display conversations for a user', (done) ->
      sqlService.messages.getConversationsForUser 1
      .then (conversations) ->
        expect(Joi.validate(conversations, schemas.ConversationListSchema).error).to.be.null
        done()
      
    it 'should display the conversations between two users', (done) ->
        sqlService.messages.getConversationBetweenUsers 1, 2
        .then (conversations) ->
          expect(Joi.validate(conversations, schemas.ConversationSchema).error).to.be.null
          done()
  
    it 'should receieve messages in ascending order', (done) ->
      sqlService.messages.addMessageBetweenUsers 1, 2, 'test message'
      .then ->
        sqlService.messages.getConversationBetweenUsers 1, 2
        .then (messages) ->
          messages[messages.length-1].message.should.equal 'test message'
          done()
  
    it 'should send a message between users', (done) ->
      sqlService.messages.addMessageBetweenUsers 1,5, 'test message'
      .then ->
        sqlService.messages.getConversationBetweenUsers 1,5
        .then (conversations) ->
          conversations.length.should.equal 1
          conversations[0].message.should.equal 'test message'
          done()
