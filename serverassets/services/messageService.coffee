db = require "../models"
sqlService = require './sqlService.js'
_ = require 'lodash'
Promise = require 'bluebird'

module.exports = 
  
  createNewConversation: ->
    db.Conversation.create()
  
  addMessageToConversation: (message, conversation) ->
    db.Message.create {message:message, ConversationId:conversation, time:new Date()}
  
    getAllConversationsForUser: (user) ->
      return new Promise (resolve, reject) ->
        sqlService.selectFromView 'getConversationHeaders', ' c WHERE `User.id` = '+user+' GROUP BY c.`Conversation.id`'
        .then (headers) ->
          if headers[0].length is 0
            resolve([])
            return
          newheaders = _.map headers[0], (header) ->
            Conversation:
              id:header['Conversation.id']
              message:header['Conversation.snippet']
              #User:
                #id:header['User.id']
                #number:header['User.number']
          resolve newheaders
          return
        return
            
    getAllMessagesForConversation: (conversation) ->
      db.Message.findAll include: [
        {
          model:db.Conversation
          where: id:conversation
          attributes:[]
        }
      ,
        {
          model:db.User
          attributes: ['id','number']
        }
      ]
      ,
      attributes:['message']
    getAllMessagesForUser: (user) ->
        db.Message.findAll include: [
          {
              model:db.User
          },
          {
            model: db.Conversation
            include: [ {
              model: db.User
              where: id: user
            } ]
          }
        ]
        
