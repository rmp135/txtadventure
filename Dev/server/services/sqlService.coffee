context = require("../models")
debug = require("debug") "txtAdventure:sqlService"
_ = require "lodash"
Promise = require "bluebird"
crypto = require 'crypto'

securityService = require '../../../Test/server/services/securityService.js'

sqlService = {}

sqlService = 
  selectFromView: (viewname, where) ->
    query = "SELECT * FROM "
    if not viewname?
      throw 'A view name must be specified.'
  
    query += viewname
    if where?
      query += ' where ' + where
    
    query += ";"
    context.query query
  
  sessions:
    createSessionForUserId: (userId) ->
      return new Promise (resolve, reject) ->
        token = crypto
        .createHash 'sha256'
        .update Math.random().toString()
        .digest 'hex'
        context.models.Session.create
          UserId:userId
          token:token
        .then (session) ->
          resolve id:session.id, token:session.token

    findByUserId: (userId) ->
      return new Promise (resolve, reject) ->
        context.models.Session.find
          where: UserId:userId
        .then (session) ->
          if not session then resolve null else resolve session.toJSON()

    deleteForUserId: (userId) ->
      return new Promise (resolve, reject) ->
        context.models.Session.destroy
          where: UserId:userId
        .then ->
          resolve()

  contacts:
    deleteContact: (contactId) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.destroy where:id:contactId
        .then ->
          resolve()
    
    addContactNumberToUser: (userId, number) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.create UserId:userId, number:number
        .then (contact) ->
          contact = contact.toJSON()
          delete contact.UserId
          resolve contact
             

    getContactsForUser: (userId) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.findAll
          where:
            UserId: userId
        .then (contacts) ->
          resolve (_.map contacts, (contact) ->
            c = contact.toJSON()
            delete c.UserId
            return c
            )
    findByNumber: (number) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.find
          where:number:number
          attributes:['id','number']
        .then (contact) ->
          if not contact then resolve null else resolve contact.toJSON()
    
    contactNumberBelongsToUser: (userId, number) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.count
          where:
            number:number
            UserId:userId
          attributes:[]
        .then (count) ->
          resolve count isnt 0
    
    contactBelongsToUser: (userId, contactId) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.count
          where:
            id:contactId
            UserId:userId
          attributes:[]
        .then (count) ->
          resolve count isnt 0

    findById: (contactId) ->
      return new Promise (resolve, reject) ->
        context.models.Contact.find
          where:
            id:contactId
          attributes:['id','number']
        .then (contact) ->
          if not contact then resolve null else resolve contact.toJSON()
        
  accounts:
    createNewAccount: (number, pin) ->
      return new Promise (resolve, reject) ->
        debug "Creating new account for number #{number}."
        
        securityService.generateHash pin
        .then (hash) ->
          context.models.User.create number:number, passHash:hash
        .then (user) ->
          resolve id:user.dataValues.id, number:user.dataValues.number

    findByNumber: (number) ->
      return new Promise (resolve, reject) ->
        context.models.User.find
          where:Number:number
        ,
          attributes: ['id','number']
        .then (user) ->
          if user then resolve id:user.dataValues.id, number:user.dataValues.number else resolve null
  
    findById: (id) ->
      return new Promise (resolve, reject) ->
        context.models.User.find
          where:
            id: id
          attributes:
            ['id','number']
        .then (user) ->
          if user then resolve user.dataValues else resolve null
    
    findBySessionToken: (sessionToken) ->
      return new Promise (resolve, reject) ->
        context.models.User.find
          include:
            [
              model:context.models.Session
              as:'Sessions'
              where:
                token:sessionToken
            ]
          attributes:['id','number']
        .then (user) ->
          if user then resolve id:user.id, number:user.number else resolve null
      
    isAuthed: (number, password) ->
      return new Promise (resolve, reject) ->
        context.models.User.find
          where:
            number:number
          attributes:['passHash']
        .then (user) ->
          return resolve false if not user
          resolve (securityService.isAuthed password, user.passHash)

  messages:
    getConversationsForUser: (userId) ->
      return new Promise (resolve, reject) ->
        query = "SELECT id ContactId, number, IFNULL(message, 'No messages.') LastMessage, UserId FROM (
          	SELECT * FROM Contact c
          	LEFT OUTER JOIN (
          			SELECT * FROM (
          				SELECT m.id MessageId, c.UserId FromUserId, u.id ToUserId, m.Message FROM Message m
          				JOIN Contact c on c.id = m.ToContactId
          				LEFT OUTER JOIN User u on u.number = c.number
          				UNION
          				SELECT m.id MessageId, u.id FromUserId,  c.UserId ToUserId, m.Message FROM Message m
          				JOIN Contact c on c.id = m.ToContactId
          				LEFT OUTER JOIN User u on u.number = c.number
          			) where FromUserId = #{userId}
          	)  m on m.ToUserId = u.id
          	LEFT OUTER JOIN USER u on u.number = c.number
          	order by MessageId asc
          ) where UserId  = #{userId} GROUP BY ContactId;"
        
        context.query query
        .then (headers) ->
          resolve _.map headers[0], (header) ->
            return {
              LastMessage:header.LastMessage
              Contact:
                id:header.ContactId
                number:header.number
            }
  
    getConversationBetweenUserAndContact: (userId, contactId) ->
      return new Promise (resolve, reject) ->
        sqlService.selectFromView 'getConversationDetails', "FromUserId = #{userId} OR ToUserId = #{userId} AND (ToContactId = #{contactId} OR ToContactId = (SELECT ID FROM Contact WHERE number = `ToContact.number`))"
        .then (results) ->
          resolve _.map results[0], (message) ->
            return {
              message:message.message
              time:new Date message.time
              from:message['FromUser.number']
              to: message['ToContact.number']
            }
    
    sendMessageToContact: (userId, contactId, message) ->
      return new Promise (resolve, reject) ->
        context.models.Message.create {
          message:message,
          ToContactId:contactId,
          time: new Date()
          }
        .then ->
          resolve()

module.exports = sqlService