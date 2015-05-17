assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"

schemas = require 'schemas'
sqlService = require 'sqlService'
securityService = require 'securityService'

root = "http://localhost:#{process.env.PORT}/api"

genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail

module.exports = describe 'UserContactsRoutesTests', ->
  describe 'Creating', ->
    it 'should 404 adding to a contact where the user does not exist', (done) ->
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user) ->
        request root
        .post "/user/999/contacts"
        .send number:user.number
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()
      
    it 'should 409 adding a contact that already exists', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:"wddsd"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
      
    it 'should 400 adding a contact with an empty string', (done) ->
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:""
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
      
    it 'should 400 adding a contact with an empty object', (done) ->
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user1) ->
        request root
        .post "/user/#{user1.id}/contacts"
        .send number:null
        .end (err, res) ->
          throw err if err
          res.status.should.equal 400
          done()
  
  describe 'Reading', ->
    it 'should return the contact as the response', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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

    it 'should return the list of contacts for a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      sqlService.accounts.createNewAccount genNumber(), genNumber()
      .then (user) ->
        request root
        .get "/user/#{user.id}/contacts"
        .end (err, res) ->
          throw err if err
          res.body.should.be.a 'array'
          res.body.should.be.empty
          done()
    
    it 'should retrive a contact for a user', (done) ->
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
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
      Promise.join (sqlService.accounts.createNewAccount genNumber(), genNumber()), (sqlService.accounts.createNewAccount genNumber(), genNumber())
      .then (users) ->
        [user1, user2] = users
        request root
        .get "/user/#{user1.id}/contacts/1"
        .end (err, res) ->
          throw err if err
          res.status.should.equal 404
          done()
