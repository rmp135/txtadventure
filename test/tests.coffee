assert = require 'mocha'
spyOn = assert.spyOn
chai = require "chai"
chai.should()
expect = chai.expect
Promise = require 'bluebird'
request = require "supertest"
Joi = require "joi"
express = require 'express'
server = require('http').createServer(require '../app')
schemas = require('../server/schemas.js')
fs = require 'fs'

rewire = require "rewire"
context = require('../server/models')

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

describe 'Services', ->
  require('../serverassets/services/SecurityServiceTests.coffee')
  require('../serverassets/services/SQLServiceTests.coffee')

describe 'API', ->
  before  ->
    server.listen(process.env.PORT)
  after ->
    server.close()
  describe 'UserRoutesTests', ->
    require '../serverassets/routes/user/UserRoutesTests.coffee'
    require '../serverassets/routes/user/contacts/UserContactsRoutesTests.coffee'
    require '../serverassets/routes/user/messages/UserMessagesRoutesTests.coffee'

