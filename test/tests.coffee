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

randomNumber = Math.floor(Math.random()*100000)

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
  describe.only 'Users', ->
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
      .get "/user/222/contacts"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()

    it.skip 'should 404 updating a user that does not exist', (done) ->
      done()

    it 'should return the list of contacts for a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount randomNumber, randomNumber), (sqlService.accounts.createNewAccount randomNumber, randomNumber)
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactToUser user1.id, user2.id
        .then ->
          request root
          .get "/user/#{user1.id}/contacts"
          .end (err, res) ->
            throw err if err
            expect(Joi.validate(res.body, schemas.ContactListSchema).error).to.be.null
            done()

    it 'should 404 returning the list of contacts for a user that does not exist', (done) ->
      request root
      .get "/user/9999/contacts/"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()
    
    it 'should return an empty array when returning a list of contacts where the user has no contacts', (done) ->
      sqlService.accounts.createNewAccount randomNumber, randomNumber
      .then (user) ->
        request root
        .get "/user/#{user.id}/contacts"
        .end (err, res) ->
          throw err if err
          res.body.should.be.a 'array'
          res.body.should.be.empty
          done()

describe 'sqlService', ->
  describe 'contacts', ->
    it 'should be able to add a new contact by id', (done) ->
      sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
      .then (user) ->
        sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
        .then (user2) ->
          sqlService.contacts.addContactToUser user.id, user2.id
          .then ->
            done()

    it 'should be able to return a list of all contacts by user', (done) ->
      sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
      .then (user) ->
        sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
        .then (user2) ->
          sqlService.contacts.addContactToUser user.id, user2.id
          .then ->
            sqlService.contacts.getContactsForUser user.id
            .then (contacts) ->
              expect(Joi.validate(contacts, schemas.ContactListSchema).error).to.be.null
              contacts.length.should.equal(1)
              contacts[0].should.equal(user2)
              done()

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
        
    it 'should show contacts if they have never sent a message', (done) ->
      sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
      .then (user) ->
        sqlService.accounts.createNewAccount (new Date().getTime()), (new Date().getTime())
        .then (user2) ->
          sqlService.contacts.addContactToUser user.id, user2.id
          .then ->
            sqlService.messages.getConversationsForUser user.id
            .then (conversations) ->
              expect(Joi.validate(conversations, schemas.ConversationListSchema).error).to.be.null
              conversations.length.should.equal 1
              conversations[0].Contact.id.should.equal user2.id
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
