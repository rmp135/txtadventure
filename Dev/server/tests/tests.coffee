global.testRequire = (name) ->
  require "../../../Test/server/#{name}"
  
server = require('http').createServer(testRequire('../app.js'))
global.localRequire = (name) ->
  require "../#{name}"
fs = require 'fs'

context = testRequire 'models'

before (done) ->
  context.createContext({storage:'test',logging:true})
  context.recreate force:true
  .then ->
    context.loadFixtures 'fixtures.sql'
  .then ->
    done()

require('./TestHelperTests.coffee')

describe 'Services', ->
  localRequire "services/SQLServiceTests.coffee"
  localRequire "services/SecurityServiceTests.coffee"

describe 'API', ->
  before  ->
    server.listen 10000
  after ->
    server.close()
  describe 'UserRoutesTests', ->
    localRequire "/routes/user/UserRoutesTests.coffee"
    localRequire "/routes/user/contacts/UserContactsRoutesTests.coffee"
    localRequire "/routes/user/messages/UserMessagesRoutesTests.coffee"
    localRequire "/routes/session/SessionRoutesTests.coffee"

