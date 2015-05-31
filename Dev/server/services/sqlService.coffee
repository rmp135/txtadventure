context = require("../models")
debug = require("debug") "txtAdventure:sqlService"
_ = require "lodash"
Promise = require "bluebird"
crypto = require 'crypto'

securityService = require '../../../Test/server/services/securityService.js'

internals = {}

internals = 
  selectFromView: (viewname, where) ->
    query = "SELECT * FROM "
    if not viewname?
      throw 'A view name must be specified.'
  
    query += viewname
    if where?
      query += ' ' + where
    
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
        query = "select c.id ContactId, c.number, IFNULL(m.message, 'No messages.') LastMessage from Contact c LEFT OUTER JOIN (
                	select * from (
                		select * from (
                			select  m.id, m.FromUserId FromUserId, u.id ToUserId, c.id ContactId, m.message, c.number from Message m JOIN Contact c on c.id = m.ToContactId LEFT OUTER JOIN User u on u.number = c.number
                			UNION ALL
                			select  m.id, u.id FromUserId, m.FromUserId ToUserId, c.id ContactId, m.message, c.number from Message m JOIN Contact c on c.id = m.ToContactId LEFT OUTER JOIN User u on u.number = c.number
                		) order by id asc
                	) where FromUserId = #{userId} GROUP BY ToUserId
                ) m on m.ContactId = c.id where c.UserId = #{userId}"
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
        context.models.Message.findAll
          where:ToContactId:contactId
          include: [
            {model:context.models.User, as:'FromUser', attributes:['number']}
          ,
            {model:context.models.Contact, as:'ToContact', attributes:['id','number']}
          ]
          attributes:['ToContactId','FromUserId', 'message']
        .then (results) ->
          resolve _.map results, (result) ->
            message = result.toJSON()
            return {
              message:message.message
              time:message.time
              from:message.FromUser.number
              to: message.ToContact.number
            }
    
    sendMessageToContact: (userId, contactId, message) ->
      return new Promise (resolve, reject) ->
        context.models.Message.create {
          message:message,
          FromUserId:userId,
          ToContactId:contactId,
          time: new Date()
          }
        .then ->
          resolve()

module.exports = internals