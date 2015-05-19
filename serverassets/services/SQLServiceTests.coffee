chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
Joi = require "joi"

schemas = require 'schemas'
context = require 'models'
sqlService = require 'sqlService'

genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail

genAccount = -> sqlService.accounts.createNewAccount genNumber(), genNumber()

module.exports = describe 'SQLService', ->
  
  describe 'Sessions', ->
    it 'should be able to create a new session for a user id', (done) ->
      genAccount()
      .then (user) ->
        sqlService.sessions.createSessionForUserId user.id
        .then (session) ->
          expect(Joi.validate(session, schemas.SessionSchema).error).to.be.null
          done()

    it 'should retrieve a session by user id', (done) ->
      genAccount()
      .then (user) ->
        sqlService.sessions.createSessionForUserId user.id
        .then (session) ->
          expect(Joi.validate(session, schemas.SessionSchema).error).to.be.null
          sqlService.sessions.findByUserId user.id
          .then (foundSession) ->
            foundSession.id.should.equal session.id
            foundSession.token.should.equal session.token
            done()

    it 'should return null if a user does not belong to a session', (done) ->
      genAccount()
      .then (user) ->
        sqlService.sessions.findByUserId user.id
        .then (foundSession) ->
          expect(foundSession).to.be.null
          done()

    it 'should remove all sessions for user', (done) ->
      genAccount()
      .then (user) ->
        sqlService.sessions.deleteForUserId user.id
        .then ->
            sqlService.sessions.findByUserId user.id
        .then (sessions) ->
          expect(sessions).to.be.null
          done()
      
      
  describe 'Accounts', ->
    it 'should create a new account by username and password', (done) ->
      number = genNumber()
      sqlService.accounts.createNewAccount number, genNumber()
      .then ->
        sqlService.accounts.findByNumber number
        .then (user) ->
          expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
          user.number.should.equal.number
          done()

    it 'should not find an account that does not exist', (done) ->
      sqlService.accounts.findByNumber genNumber()
      .then (user) ->
        expect(user).to.be.null
        done()

    it 'should find an account that does exist', (done) ->
      number = genNumber()
      sqlService.accounts.createNewAccount number, genNumber()
      .then ->
        sqlService.accounts.findByNumber number
        .then (user) ->
          expect(Joi.validate(user, schemas.ContactSchema).error).to.be.null
          user.number.should.equal.number
          done()
    
    it 'should return true when a number and password are authenticated', (done) ->
      number = genNumber()
      password = genNumber()
      sqlService.accounts.createNewAccount number, password
      .then ->
        sqlService.accounts.isAuthed number, password
        .then (response) ->
          response.should.equal.true
          done()

    it 'should return false when a number and password are not authenticated', (done) ->
      number = genNumber()
      sqlService.accounts.createNewAccount number, genNumber()
      .then ->
        sqlService.accounts.isAuthed number, 'notpassword'
        .then (response) ->
          response.should.equal.false
          done()
          
    it 'should return a user by session token', (done) ->
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        sqlService.sessions.createSessionForUserId user1.id
        .then (session) ->
          sqlService.accounts.findBySessionToken session.token
          .then (user2) ->
            user2.should.eql user1
            done()
    
    it 'should return null finding a user with no session', (done) ->
      sqlService.accounts.findBySessionToken "notatoken"
      .then (user) ->
        expect(user).to.be.null
        done()
      

  describe 'Contacts', ->
    it 'should return true if a contact belongs to a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then (contact) ->
          sqlService.contacts.contactBelongsToUser user1.id, contact.id
        .then (belongs) ->
          belongs.should.be.true
          done()

    it 'should return false if a contact does not belong to a user', (done) ->
      Promise.join sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        sqlService.contacts.contactBelongsToUser user1.id, 1
        .then (belongs) ->
          belongs.should.be.false
          done()

    it 'should return false if the contact does not exist', (done) ->
      Promise.join sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        sqlService.contacts.contactBelongsToUser 222, 1
        .then (belongs) ->
          belongs.should.be.false
          done()

    it 'should return false if the user does not exist', (done) ->
      Promise.join sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        sqlService.contacts.contactBelongsToUser user1.id, 999999
        .then (belongs) ->
          belongs.should.be.false
          done()
      
      
    it 'should be able to add a new contact by number', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then ->
          done()

    it 'should be able to return a list of all contacts by user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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

    it 'should be able to delete a contact', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
      .then (users) ->
        [user1, user2] = users
        sqlService.contacts.addContactNumberToUser user1.id, user2.number
        .then ->
          sqlService.contacts.addContactNumberToUser user1.id, "077547575318"
        .then (contact) ->
          sqlService.contacts.deleteContact contact.id
          .then ->
            sqlService.contacts.getContactsForUser user1.id
            .then (contacts) ->
              expect(Joi.validate(contacts, schemas.ContactListSchema).error).to.be.null
              contacts.length.should.equal(1)
              contacts[0].id.should.equal.exist
              contacts[0].number.should.equal user2.number
              done()
      
  
  describe 'Messaging', ->
    it 'should display conversations for a user', (done) ->
      sqlService.messages.getConversationsForUser 1
      .then (conversations) ->
        expect(Joi.validate(conversations, schemas.ConversationListSchema).error).to.be.null
        done()
        
    it 'should show conversations for a user if they have never sent a message', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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