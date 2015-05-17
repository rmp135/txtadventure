assert = require 'mocha'
spyOn = assert.spyOn
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
fs = require 'fs'

rewire = require "rewire"
context = require('../server/models')
sqlService = require '../server/services/sqlService.js'
securityService = require '../server/services/securityService.js'

genString = -> (Math.floor(Math.random()*100000)).toString()

it 'should generate a new random number each time', ->
  number = genString()
  number2 = genString()
  number.should.not.equal number2

before (done) ->
  fs.unlink 'test.sqlite3'
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
      sqlService.accounts.createNewAccount genString(), genString()
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
  describe 'Contacts', ->
    it 'should return the contact as the response', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:user2.number
        .end (err, res) ->
          throw err if err
          res.status.should.equal 200
          expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
          done()
    it 'should 404 adding to a contact where the user does not exist', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user) ->
        request root
        .post "/user/999/contacts"
        .send number:user.number
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()
      
    it 'should 409 adding a contact that already exists', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then ->
          request root
          .post "/user/#{user1.id}/contacts"
          .send number:user2.number
          .end (err, res) ->
            throw err if err
            res.status.should.equal 409
            done()

    it 'should 400 adding a contact using letters', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:"wddsd"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
      
    it 'should 400 adding a contact with an empty string', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:""
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
      
    it 'should 400 adding a contact with an empty object', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:null
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
    
    it 'should return the list of contacts for a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
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
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user) ->
        request root
        .get "/user/#{user.id}/contacts"
        .end (err, res) ->
          throw err if err
          res.body.should.be.a 'array'
          res.body.should.be.empty
          done()

    it 'should retrive a contact for a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .get "/user/#{user1.id}/contacts/#{contact.id}"
          .end (err, res) ->
            throw err if err
            res.status.should.equal 200
            expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
            done()

    it 'should 404 retrieving a contact that does not exist', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .get "/user/#{user1.id}/contacts/9999"
          .end (err, res) ->
            throw err if err
            res.status.should.equal 404
            done()

    it 'should 404 retrieving a contact for a user that does not exist', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .get "/user/9999/contacts/#{contact.id}"
          .end (err, res) ->
            throw err if err
            res.status.should.equal 404
            done()

    it 'should 404 retrieving a contact that does not belong to a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        request root
        .get "/user/#{user1.id}/contacts/1"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()

  describe 'Messages', ->
    it 'should be able to send a message to a contact', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .post "/user/#{user1.id}/messages/#{contact.id}"
          .send message:"test message"
          .end (err, res) ->
            throw err if err
            res.status.should.equal 200
            done()

    it 'should be able to send multiple messages to the same contact', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          sqlService.messages.sendMessageToContact user1.id, contact.id, "test message"
          .then ->
            request root
            .post "/user/#{user1.id}/messages/#{contact.id}"
            .send message:"test message"
            .end (err, res) ->
              throw err if err
              res.status.should.equal 200
              done()
      
    it 'should 404 sending from a user that does not exist', (done) ->
      request root
      .post "/user/99999/messages/1"
      .send message:"test message"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()
      
    it 'should 404 sending to a contact that the user does not know', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        request root
        .post "/user/#{user1.id}/messages/1"
        .send message:"test message"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()
    
    it 'should 404 sending to a contact that does not exist', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        request root
        .post "/user/#{user1.id}/messages/99999"
        .send message:"test message"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()

    it 'should not show messages from other contacts', (done) ->
      createAccount = -> sqlService.accounts.createNewAccount genString(), genString()
      Promise.join createAccount(), createAccount(), createAccount()
      .then (users) ->
        [user1, user2, user3] = users
        Promise.join (sqlService.contacts.addContactNumberToUser user1.id, user3.number), (sqlService.contacts.addContactNumberToUser user2.id, user3.number)
        .then (contacts) ->
          [u1Contact, u2Contact] = contacts
          sqlService.messages.sendMessageToContact user2.id, u2Contact.id, "test message"
          .then ->
            request root
            .get "/user/#{user1.id}/messages/#{u1Contact.id}"
            .end (err, res) ->
              throw err if err
              res.status.should.equal 200
              expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
              res.body.length.should.equal 0
              done()
      
    it 'should be able to list messages between a user and a contact', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          sqlService.messages.sendMessageToContact user1.id, contact.id, "test message"
          .then ->
            request root
            .get "/user/#{user1.id}/messages/#{contact.id}"
            .end (err, res) ->
              throw err if err
              res.status.should.equal 200
              expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
              res.body[0].message.should.equal "test message"
              done()

    it 'should 404 finding messages for a user that does not exist', (done) ->
      request root
      .get "/user/9999/messages/1"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()

    it 'should 404 finding message for a contact that the user does not know', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        request root
        .get "/user/#{user1.id}/messages/1"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()

    it 'should 404 finding messages for a contact that does not exist', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        request root
        .get "/user/#{user1.id}/messages/999999"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()

    it 'should 400 attempting to send a blank message', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .post "/user/#{user1.id}/messages/#{contact.id}"
          .send message:""
          .end (err, res) ->
            throw err if err
            res.status.should.equal 400
            done()

    it 'should 400 attempting to send a message with no content', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          request root
          .post "/user/#{user1.id}/messages/#{contact.id}"
          .send()
          .end (err, res) ->
            throw err if err
            res.status.should.equal 400
            done()

    it 'should retrieve messages for a contact that is not a user', (done) ->
      sqlService.accounts.createNewAccount genString(), genString()
      .then (user1) ->
        sqlService.contacts.addContactNumberToUser user1.id, "08872323222"
        .then (contact) ->
          sqlService.messages.sendMessageToContact user1.id, contact.id, "test message"
          .then ->
            request root
            .get "/user/#{user1.id}/messages/#{contact.id}"
            .end (err, res) ->
              throw err if err
              res.status.should.equal 200
              expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
              res.body[0].message.should.equal "test message"
              done()

describe 'Services', ->
  describe 'securityService', ->
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

  describe 'sqlService', ->
    describe 'accounts', ->
  
      it 'should create a new account by username and password', (done) ->
        number = genString()
        sqlService.accounts.createNewAccount number, genString()
        .then ->
          sqlService.accounts.findByNumber number
          .then (user) ->
            expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
            user.number.should.equal.number
            done()
  
      it 'should not find an account that does not exist', (done) ->
        sqlService.accounts.findByNumber genString()
        .then (user) ->
          expect(user).to.be.null
          done()
  
      it 'should find an account that does exist', (done) ->
        number = genString()
        sqlService.accounts.createNewAccount number, genString()
        .then ->
          sqlService.accounts.findByNumber number
          .then (user) ->
            expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
            user.number.should.equal.number
            done()
      
      it 'should return true when a number and password are authenticated', (done) ->
        number = genString()
        password = genString()
        sqlService.accounts.createNewAccount number, password
        .then ->
          sqlService.accounts.isAuthed number, password
          .then (response) ->
            response.should.equal.true
            done()

      it 'should return false when a number and password are not authenticated', (done) ->
        number = genString()
        sqlService.accounts.createNewAccount number, genString()
        .then ->
          sqlService.accounts.isAuthed number, 'notpassword'
          .then (response) ->
            response.should.equal.false
            done()

    describe 'contacts', ->
      it 'should return true if a contact belongs to a user', (done) ->
        Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
        .then (users) ->
          [user1, user2] = users
          sqlService.contacts.addContactNumberToUser user1.id, user2.number
          .then (contact) ->
            sqlService.contacts.contactBelongsToUser user1.id, contact.id
          .then (belongs) ->
            belongs.should.be.true
            done()

      it 'should return false if a contact does not belong to a user', (done) ->
        Promise.join sqlService.accounts.createNewAccount genString(), genString()
        .then (user1) ->
          sqlService.contacts.contactBelongsToUser user1.id, 1
          .then (belongs) ->
            belongs.should.be.false
            done()

      it 'should return false if the contact does not exist', (done) ->
        Promise.join sqlService.accounts.createNewAccount genString(), genString()
        .then (user1) ->
          sqlService.contacts.contactBelongsToUser 222, 1
          .then (belongs) ->
            belongs.should.be.false
            done()

      it 'should return false if the user does not exist', (done) ->
        Promise.join sqlService.accounts.createNewAccount genString(), genString()
        .then (user1) ->
          sqlService.contacts.contactBelongsToUser user1.id, 999999
          .then (belongs) ->
            belongs.should.be.false
            done()
        
        
      it 'should be able to add a new contact by number', (done) ->
        Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
        .then (users) ->
          [user1, user2] = users
          sqlService.contacts.addContactNumberToUser user1.id, user2.number
          .then ->
            done()

      it 'should be able to return a list of all contacts by user', (done) ->
        Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
        .then (users) ->
          [user1, user2] = users
          sqlService.contacts.addContactNumberToUser user1.id, user2.number
          .then ->
            sqlService.contacts.addContactNumberToUser user1.id, "077547575318"
          .then ->
            sqlService.contacts.getContactsForUser user1.id
            .then (contacts) ->
              expect(Joi.validate(contacts, schemas.ContactListSchema).error).to.be.null
              contacts.length.should.equal(2)
              contacts[0].id.should.equal.exist
              contacts[0].number.should.equal user2.number
              contacts[1].id.should.exist
              contacts[1].number.should.equal "077547575318"
              done()
    
    describe 'messaging', ->
      it 'should display conversations for a user', (done) ->
        sqlService.messages.getConversationsForUser 1
        .then (conversations) ->
          expect(Joi.validate(conversations, schemas.ConversationListSchema).error).to.be.null
          done()
          
      it 'should show conversations for a user if they have never sent a message', (done) ->
        Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
        .then (users) ->
          [user1, user2] = users
          sqlService.contacts.addContactNumberToUser user1.id, user2.number
          .then ->
            sqlService.messages.getConversationsForUser user1.id
            .then (conversations) ->
              expect(Joi.validate(conversations, schemas.ConversationListSchema).error).to.be.null
              conversations.length.should.equal 1
              done()
          
        
      it 'should display the conversations betweena user and a contact', (done) ->
          sqlService.messages.getConversationBetweenUserAndContact 1, 1
          .then (conversations) ->
            expect(Joi.validate(conversations, schemas.ConversationSchema).error).to.be.null
            done()
    
      it 'should send a message between a user and a contact', (done) ->
        Promise.join (sqlService.accounts.createNewAccount genString(), genString()), (sqlService.accounts.createNewAccount genString(), genString())
        .then (users) ->
          [user1, user2] = users
          sqlService.contacts.addContactNumberToUser user1.id, user2.number
          .then ->
            sqlService.contacts.getContactsForUser user1.id
          .then (contacts) ->
            sqlService.messages.sendMessageToContact user1.id, contacts[0].id, "this is a test"
            .then ->
              sqlService.messages.getConversationBetweenUserAndContact user1.id, contacts[0].id
            .then (messages) ->
              expect(Joi.validate(messages, schemas.ConversationSchema).error).to.be.null
              messages.length.should.equal 1
              done()