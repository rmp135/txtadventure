db = require("../models")
debug = require("debug") "txtAdventure:sqlService"
_ = require "lodash"
Promise = require "bluebird"

context = db.createContext({storage:'db',logging:true})
context.sync()

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
  findByNumber: (id) ->
    context.models.User.find where:Number:id
    
exports.messages = 
  getConversationsForUser: (userId) ->
    return new Promise (resolve, reject) ->
      selectFromView 'getConversationHeaders', "WHERE UserId = #{userId}"
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
      Promise.join (context.models.User.find where:id:user2), (selectFromView 'getConversationDetails', "WHERE `From.id` IN(#{user1},#{user2}) AND `To.id` IN(#{user1},#{user2});")
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