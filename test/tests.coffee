express = require 'express'
server = require('http').createServer(require '../app')
fs = require 'fs'

context = require 'models'

before (done) ->
  fs.unlink 'test.sqlite3'
  context.createContext({storage:'test',logging:true})
  context.recreate force:true
  .then ->
    context.loadFixtures 'fixtures.sql'
  .then ->
    done()

require('./TestHelperTests.coffee')

describe 'Services', ->
  require('../serverassets/services/SQLServiceTests.coffee')

describe 'API', ->
  before  ->
    server.listen process.env.PORT
  after ->
    server.close()
  describe 'UserRoutesTests', ->
    require '../serverassets/routes/user/UserRoutesTests.coffee'
    require '../serverassets/routes/user/contacts/UserContactsRoutesTests.coffee'
    require '../serverassets/routes/user/messages/UserMessagesRoutesTests.coffee'
    require '../serverassets/routes/session/SessionRoutesTests.coffee'

