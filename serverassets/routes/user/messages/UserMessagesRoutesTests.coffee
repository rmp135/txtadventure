assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"
schemas = require('../../../../server/schemas.js')

sqlService = require '../../../../server/services/sqlService.js'

root = "http://localhost:#{process.env.PORT}/api"

genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail


module.exports = describe 'UserMessagesRoutesTests', ->
  it 'should be able to send a message to a contact', (done) ->
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    createAccount = -> sqlService.accounts.createNewAccount genNumber(), genNumber()
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
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    sqlService.accounts.createNewAccount genNumber(), genNumber()
    .then (user1) ->
      request root
      .get "/user/#{user1.id}/messages/1"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()
  
  it 'should 404 finding messages for a contact that does not exist', (done) ->
    sqlService.accounts.createNewAccount genNumber(), genNumber()
    .then (user1) ->
      request root
      .get "/user/#{user1.id}/messages/999999"
      .end (err, res) ->
        throw err if err
        res.status.should.equal 404
        done()
  
  it 'should 400 attempting to send a blank message', (done) ->
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
    sqlService.accounts.createNewAccount genNumber(), genNumber()
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