sqlService = require 'sqlService'
Promise = require 'bluebird'
request = require 'supertest'
testHelper = require 'testHelper'

describe 'TestHelper', ->
  it 'should generate a random number each time', (done) ->
    Promise.join testHelper.genNumber(), testHelper.genNumber()
    .then (numbers) ->
      numbers[0].should.not.equal numbers[1]
      done()
      
  it 'should generate a random password each time', (done) ->
    Promise.join testHelper.genPassword(), testHelper.genPassword()
    .then (passwords) ->
      passwords[0].should.not.equal passwords[1]
      done()
    
  it 'should log a user in with a given username and password', (done) ->
    number = testHelper.genNumber()
    password = testHelper.genPassword()
    testHelper.login number, password
    .then (userDetails) ->
      {user, session} = userDetails
      user.should.have.property 'id'
      user.should.have.property 'number'
      user.number.should.equal number
      session.should.have.property 'token'
      done()

  it 'should log a user in', (done) ->
    testHelper.login()
    .then (userDetails) ->
      {user, session} = userDetails
      user.should.have.property 'id'
      user.should.have.property 'number'
      session.should.have.property 'token'
      done()
  
  it 'should create an account with a given name and password', (done) ->
    number = testHelper.genNumber()
    password = testHelper.genPassword()
    testHelper.createAccount number, password
    .then (user) ->
      user.should.have.property 'id'
      user.should.have.property 'number'
      user.number.should.equal number
      done()

  it 'should create an account with a random name and password', (done) ->
    testHelper.createAccount()
    .then (user) ->
      user.should.have.property 'id'
      user.should.have.property 'number'
      done()