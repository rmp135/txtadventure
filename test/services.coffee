assert = require 'mocha'
should = require 'should'
sqlService = require '../server/services/sqlService.js'
messageService = require '../server/services/messageService.js'

describe 'messageService', ->
    describe 'Conversations', ->
        it 'should add a message to an existing conversation', (done) ->
            false.should.equal true
            done()
        it 'should create a new conversation if none was specified', (done) ->
            false.should.equal true
            done()
        it 'should return conversations in which a user has sent a message', (done) ->
            false.should.equal true
            done()
        it 'should return conversations that a user has not sent a message but is involved', (done) ->
            false.should.equal true
            done()
