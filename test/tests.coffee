assert = require 'mocha'
should = require 'should'
db = require('../server/models')
rewire = require "rewire"
sqlService = rewire '../server/services/sqlService.js'
Promise = require 'bluebird'
schema = require 'js-schema'
debug = require("debug") "test"

before (done) ->
    context = db.createContext({storage:'test',logging:true})
    context.sync force:true
    .then ->
        sqlService.__set__ "context", context
        context.loadFixtures 'fixtures.sql'
        .then ->
            done()

describe.skip 'Users', ->
    it 'should create a new user', (done)->
        context.models.User.create number:'001'
        .then (user)->
            context.models.User.find where: id:user.id
            .then (user) ->
                user.number.should.equal '001'
                done()
                return

    it 'should add a new contact', (done) ->
        Promise.join (context.models.User.create number: '001'), (context.models.User.create number: '002')
        .then (users) ->
            users[0].addContact users[1]
            .then ->
                users[0].getContacts()
                .then (contacts) ->
                    contacts.length.should.equal 1
                    contacts[0].number.should.equal users[1].number
                    done()

describe 'accounts', ->
    it 'should not found an account that does not exist', (done) ->
        sqlService.accounts.findByNumber '020'
        .then (user) ->
            should.not.exist user
            done()
            
    it 'should find an account that does exist', (done) ->
        sqlService.accounts.findByNumber '001'
        .then (user) ->
            user.id.should.equal 1
            user.number.should.equal '001'
            done()

describe.only 'messageService', ->
  ContactSchema = schema(
    id:Number
    number:String
    )
  ConversationListSchema = schema(
    Array.of(
      LastMessage:String
      Contact:ContactSchema
      )
    )
  ConversationSchema = schema(
    Array.of(
      From:ContactSchema
      To:ContactSchema
      message:String
      )
    )
  MessageSchema = schema(
    message:String
    To:ContactSchema
    )
    
  it 'should display conversations for a user', (done) ->
    sqlService.messages.getConversationsForUser 1
    .then (conversations) ->
      ConversationListSchema.errors(conversations).should.be.false
      done()
    
  it 'should display the conversations between two users', (done) ->
      sqlService.messages.getConversationBetweenUsers 1, 2
      .then (conversations) ->
        ConversationSchema.errors(conversations).should.be.false
        done()
  it 'should send a message between users', (done) ->
    sqlService.messages.addMessageBetweenUsers 1,5, 'test message'
    .then ->
      sqlService.messages.getConversationBetweenUsers 1,5
      .then (conversations) ->
        conversations.length.should.equal 1
        conversations[0].message.should.equal 'test message'
        done()
