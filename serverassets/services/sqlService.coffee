context = require("../models")
debug = require("debug") "txtAdventure:sqlService"
_ = require "lodash"
Promise = require "bluebird"

selectFromView = (viewname, where) ->
  query = "SELECT * FROM "
  if not viewname?
    throw 'A view name must be specified.'

  query += viewname
  if where?
    query += ' ' + where
  
  query += ";"
  context.query query

exports.selectFromView = selectFromView
exports.accounts =
  createNewAccount: (number, pin) ->
    return new Promise (resolve, reject) ->
      context.models.User.create number:number, pin:pin
      .then (user) ->
        resolve id: user.dataValues.id, number:user.dataValues.number
      
    
  findByNumber: (number) ->
    return new Promise (resolve, reject) ->
      context.models.User.find
        where:Number:number
      ,
        attributes: ['id','number']
      .then (user) ->
        if user then resolve user.dataValues else resolve null

  findById: (id) ->
    return new Promise (resolve, reject) ->
      context.models.User.find
        where:
          id: id
        attributes:
          ['id','number']
      .then (user) ->
        if user then resolve user.dataValues else resolve null

exports.messages = 
  getConversationsForUser: (userId) ->
    return new Promise (resolve, reject) ->
      selectFromView 'getConversationHeaders', "WHERE UserId = #{userId} OR UserId IS NULL GROUP BY ContactId"
      .then (headers) ->
        resolve _.map headers[0], (header) ->
          return {
            LastMessage:header.LastMessage
            Contact:
              id:header.ContactId
              number:header.number
          }

  getConversationBetweenUsers: (user1, user2) ->
    return new Promise (resolve, reject) ->
      Promise.join (context.models.User.find where:id:user2), (selectFromView 'getConversationDetails', "WHERE `From.id` IN(#{user1},#{user2}) AND `To.id` IN(#{user1},#{user2}) ORDER BY id ASC;")
      .then (results) ->
        u = results[0]
        messages = results[1][0]
        resolve _.map messages, (result) ->
            {
              message:result.message,
              From:
                id: result['From.id']
                number: result['From.number']
              To:
                id: result['To.id']
                number: result['To.number']
            }
          
  addMessageBetweenUsers: (user1, user2, message) ->
    return new Promise (resolve, reject) ->
      context.models.Message.create {
        message:message,
        FromUserId:user1,
        ToUserId:user2,
        time: new Date()
        }
      .then ->
        resolve()