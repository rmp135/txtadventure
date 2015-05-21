assert = require 'mocha'
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"

schemas = testRequire 'schemas.js'
sqlService = testRequire 'services/sqlService.js'
securityService = testRequire 'services/securityService.js'

testHelper = localRequire '../tests/testHelper.coffee'

root = "http://localhost:10000/api"

module.exports = describe 'UserContactsRoutesTests', ->
  
  user = session = user2 = null
  beforeEach 'Create users.', (done) ->
    Promise.join testHelper.login(), testHelper.login()
    .then (loginDetails) ->
      [{user, session}, {user:user2}] = loginDetails
      done()

  
  describe 'Creating', ->
    it 'should 403 adding to a contact where the user does not exist', (done) ->
      request root
      .post "/user/999/contacts"
      .send number:user.number
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 adding to a contact where the user does not have permission', (done) ->
      request root
      .post "/user/1/contacts"
      .send number:user.number
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
      
    it 'should 409 adding a contact that already exists', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then ->
        request root
        .post "/user/#{user.id}/contacts"
        .setSession session
        .send number:user2.number
        .endAsync()
      .then (res) ->
        res.status.should.equal 409
        done()
    
    it 'should 400 adding a contact using letters', (done) ->
      request root
      .post "/user/#{user.id}/contacts"
      .setSession session
      .send number:"wddsd"
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
      
    it 'should 400 adding a contact with an empty string', (done) ->
      request root
      .post "/user/#{user.id}/contacts"
      .send number:""
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
      
    it 'should 400 adding a contact with an empty object', (done) ->
      request root
      .post "/user/#{user.id}/contacts"
      .send number:null
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 400
        done()
  
  describe 'Reading', ->
    it 'should return the contact as the response', (done) ->
      request root
      .post "/user/#{user.id}/contacts"
      .send number:user2.number
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
        done()

    it 'should return the list of contacts for a user', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then ->
        request root
        .get "/user/#{user.id}/contacts"
        .setSession session
        .endAsync()
      .then (res) ->
        expect(Joi.validate(res.body, schemas.ContactListSchema).error).to.be.null
        done()
    
    it 'should 403 when returning contacts if the session is not available', (done) ->
        request root
        .get "/user/1/contacts/"
        .set 'Cookie', 'session=222'
        .endAsync()
        .then (res) ->
          res.status.should.equal 403
          done()

    it 'should 403 when returning a contact if the session is not available', (done) ->
        request root
        .get "/user/1/contacts/1"
        .set 'Cookie', 'session=222'
        .endAsync()
        .then (res) ->
          res.status.should.equal 403
          done()

    it 'should 403 returning the list of contacts for a user that does not exist', (done) ->
      request root
      .get "/user/9999/contacts/"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 returning the list of contacts for a user if the user does not have permission', (done) ->
      request root
      .get "/user/9999/contacts/"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
    
    it 'should return an empty array when returning a list of contacts where the user has no contacts', (done) ->
      request root
      .get "/user/#{user.id}/contacts"
      .setSession session
      .endAsync()
      .then (res) ->
        res.body.should.be.a 'array'
        res.body.should.be.empty
        done()
    
    it 'should retrive a contact for a user', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .get "/user/#{user.id}/contacts/#{contact.id}"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 200
        expect(Joi.validate(res.body, schemas.ContactSchema).error).to.be.null
        done()
    
    it 'should 404 retrieving a contact that does not exist', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .get "/user/#{user.id}/contacts/9999"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()
    
    it 'should 403 retrieving a contact for a user that does not have permission', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .get "/user/1/contacts/#{contact.id}"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 retrieving a contact for a user that does not exist', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .get "/user/9999/contacts/#{contact.id}"
        .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
    
    it 'should 404 retrieving a contact that does not belong to a user', (done) ->
      request root
      .get "/user/#{user.id}/contacts/1"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()

  describe 'Destroying', ->
    it 'should allow a user to delete a contact', (done) ->
      sqlService.contacts.addContactNumberToUser user.id, user2.number
      .then (contact) ->
        request root
        .delete "/user/#{user.id}/contacts/#{contact.id}"
        .setSession session
        .endAsync()
      .then (res) ->
        res.status.should.equal 200
        done()

    it 'should 403 when deleting a contact if the session is not available', (done) ->
        request root
        .get "/user/1/contacts/1"
        .set 'Cookie', 'session=222'
        .endAsync()
        .then (res) ->
          res.status.should.equal 403
          done()
        
    it 'should 403 deleting a contact if the user does not have permission', (done) ->
      request root
      .delete "/user/1/contacts/1"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()

    it 'should 403 deleting a contact if the user does not exist', (done) ->
      request root
      .delete "/user/9999/contacts/1"
      .endAsync()
      .then (res) ->
        res.status.should.equal 403
        done()
      
    it 'should 404 deleting a contact if the contact does not exist', (done) ->
      request root
      .delete "/user/#{user.id}/contacts/99999"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()
      
    it 'should 404 deleting a contact if the contact does not belong to the user', (done) ->
      request root
      .delete "/user/#{user.id}/contacts/1"
      .setSession session
      .endAsync()
      .then (res) ->
        res.status.should.equal 404
        done()