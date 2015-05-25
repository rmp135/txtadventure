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

module.exports = describe 'UserMessagesRoutesTests', ->
  user = session = user2 = null
  beforeEach 'Create users.', (done) ->
    Promise.join testHelper.login(), testHelper.login()
    .then (loginDetails) ->
      [{user, session}, {user:user2}] = loginDetails
      done()
    
  describe 'Creating', ->
    it 'should be able to send a message to a contact', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .post "/user/#{user.id}/messages/#{contact.id}"
        .setSession session
        .send message:"test message"
        .endAsync()
      .then (res) ->
        res.status.should.equal 200
        done()

    it 'should be able to send multiple messages to the same contact', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        sqlService.messages.sendMessageToContact user.id, contact.id, "test message"
        .then ->
          request root
          .post "/user/#{user.id}/messages/#{contact.id}"
          .setSession session
          .send message:"test message"
          .endAsync()
      .then (res) ->
        res.status.should.equal 200
        done()
      
    it 'should 403 sending from an account that does not exist', (done) ->
      request root
      .post "/user/99999/messages/1"
      .send message:"test message"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 sending from an account that the user is not authenticated for', (done) ->
      request root
      .post "/user/1/messages/1"
      .setSession session
      .send message:"test message"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 when sending a message if the session is not available', (done) ->
      request root
      .post "/user/1/messages/1"
      .send message:"test message"
      .set 'Cookie', 'session=222'
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
      
    it 'should 403 sending from an account that does not belong to the user', (done) ->
      request root
      .post "/user/1/messages/1"
      .send message:"test message"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
      
    it 'should 404 sending to a contact that the user does not know', (done) ->
      request root
      .post "/user/#{user.id}/messages/1"
      .setSession session
      .send message:"test message"
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()
  
    it 'should 404 sending to a contact that does not exist', (done) ->
      request root
      .post "/user/#{user.id}/messages/99999"
      .send message:"test message"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()

    it 'should 400 attempting to send a message with no content', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .post "/user/#{user.id}/messages/#{contact.id}"
        .setSession session
        .send()
        .endAsync()
        .then (res) ->
          res.status.should.equal 400
          done()          

    it 'should 400 attempting to send a blank message', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .post "/user/#{user.id}/messages/#{contact.id}"
        .setSession session
        .send message:""
        .endAsync()
        .then (res) ->
          res.status.should.equal 400
          done()
    
  describe 'Reading', ->
    it 'shold show message headers for a user that has contacts', (done) ->
      testHelper.createAccount()
      .then (user3) ->
        Promise.join (sqlService.contacts.addContactNumberToUser user.id, user2.number), (sqlService.contacts.addContactNumberToUser user.id, user3.number)
        .then (contacts) ->
          request root
          .get "/user/#{user.id}/messages"
          .setSession session
          .endAsync()
      .then (res) ->
        res.body.length.should.equal 2
        done()
      
    
    it 'should show no message headers if a user has no contacts', (done) ->
      request root
      .get "/user/#{user.id}/messages"
      .setSession session
      .endAsync()
      .then (res) ->
        res.body.length.should.equal 0
        done()
      
    
    it 'should not show messages from other contacts', (done) ->
      testHelper.createAccount()
      .then (user3) ->
        Promise.join (sqlService.contacts.addContactNumberToUser user.id, user3.number), (sqlService.contacts.addContactNumberToUser user2.id, user3.number)
        .then (contacts) ->
          [u1Contact, u2Contact] = contacts
          sqlService.messages.sendMessageToContact user2.id, u2Contact.id, "test message"
          .then ->
            request root
            .get "/user/#{user.id}/messages/#{u1Contact.id}"
            .setSession session
            .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
        res.body.length.should.equal 0
        done()
      
    it 'should be able to list messages between a user and a contact', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        sqlService.messages.sendMessageToContact user.id, contact.id, "test message"
        .then ->
          request root
          .get "/user/#{user.id}/messages/#{contact.id}"
          .setSession session
          .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
        res.body[0].message.should.equal "test message"
        done()
    
    it 'should 403 finding messages for a user that does not exist', (done) ->
      request root
      .get "/user/9999/messages/1"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
    
    it 'should 404 finding messages for a contact that the user does not know', (done) ->
      request root
      .get "/user/#{user.id}/messages/1"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()
    
    it 'should 404 finding messages for a contact that does not exist', (done) ->
      request root
      .get "/user/#{user.id}/messages/999999"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()
    
    it 'should retrieve messages for a contact that is not a user', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, "0123456789"
      .then (contact) ->
        sqlService.messages.sendMessageToContact user.id, contact.id, "test message"
        .then ->
          request root
          .get "/user/#{user.id}/messages/#{contact.id}"
          .setSession session
          .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ConversationSchema).error).to.be.null
        res.body[0].message.should.equal "test message"
        done()