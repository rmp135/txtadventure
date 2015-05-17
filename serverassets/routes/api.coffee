express = require 'express'
router = express.Router()
sqlService = require '../services/sqlService.js'
schemas = require '../schemas.js'
validate = require "express-validation"
debug = require("debug") "txtAdventure:api"
Promise = require 'bluebird'

logResponseBody = (req, res, next) ->
  oldWrite = res.write
  oldEnd = res.end
  chunks = []

  res.write = (chunk) ->
    chunks.push chunk
    oldWrite.apply res, arguments
    return

  res.end = (chunk) ->
    if chunk
      chunks.push chunk
    body = Buffer.concat(chunks).toString('utf8')
    debug "Response: #{body}" if res.statusCode is 200
    oldEnd.apply res, arguments
    return

  next()
  return

router.use logResponseBody

router.use (req, res, next) ->
  debug "Request: #{JSON.stringify req.body}"
  next()

router.route '/login'
.post (req, res) ->
    sqlService.accounts.findById req.body.id
    .then (user) ->
        if not user
            res.sendStatus 403

router.post '/user', validate(body:schemas.UserCreateSchema), (req, res) ->
    sqlService.accounts.createNewAccount req.body.number, req.body.pin
    .then (user) ->
        res.json user

router.get '/user/:id', (req, res) ->
  debug sqlService.accounts
  sqlService.accounts.findById req.params.id
  .then (user) ->
    debug user
    if user
      res.json user
    else
      res.sendStatus 404

router.get '/user/:id/contacts', (req, res) ->
  sqlService.accounts.findById req.params.id
  .then (user) ->
    if not user
      res.sendStatus 404
    else
      sqlService.contacts.getContactsForUser req.params.id
      .then (contacts) ->
        res.json contacts

router.post '/user/:id/contacts', validate(body:schemas.ContactAddSchema), (req, res) ->
  Promise.join (sqlService.accounts.findById req.params.id), (sqlService.contacts.contactNumberBelongsToUser req.params.id, req.body.number)
  .then (results) ->
    [user, belongs] = results
    if not user then return res.sendStatus 404
    if belongs then return res.sendStatus 409
    sqlService.contacts.addContactNumberToUser req.params.id, req.body.number
    .then (contact) ->
      res.json contact
  
    
router.get '/user/:id/contacts/:conid', (req, res) ->
  Promise.join (sqlService.accounts.findById req.params.id), (sqlService.contacts.findById req.params.conid), (sqlService.contacts.contactBelongsToUser req.params.id, req.params.conid)
  .then (results) ->
    [user, contact, belongs] = results
    if not user or not contact or not belongs then return res.sendStatus 404
    res.send contact
  

router.get '/user/:userid/messages/:conid', (req,res) ->
  Promise.join (sqlService.accounts.findById req.params.userid), (sqlService.contacts.findById req.params.conid), (sqlService.contacts.contactBelongsToUser req.params.userid, req.params.conid)
  .then (results) ->
    [user, contact, belongs] = results
    if not user or not contact or not belongs then return res.sendStatus 404
    sqlService.messages.getConversationBetweenUserAndContact req.params.userid, req.params.conid
    .then (messages) ->
        res.json messages

router.post '/user/:userid/messages/:conid', validate(body:schemas.NewMessageSchema), (req, res) ->
  sqlService.contacts.contactBelongsToUser req.params.userid, req.params.conid
  .then (belongs) ->
    if belongs is false
      return res.sendStatus 404
    sqlService.accounts.findById req.params.userid
    .then (user) ->
      if not user?
        res.sendStatus 404
      else
        sqlService.messages.sendMessageToContact req.params.userid, req.params.conid, req.body.message
        .then ->
            res.sendStatus 200

router.route '/user/:id/messages'
.get (req,res) ->
    sqlService.messages.getConversationsForUser req.params.id
    .then (conversations) ->
        res.json conversations

#router.use (err, req, res, next) ->
  #debug "Response: #{res}"
  #next()    

#router.use (err, req, res, next) ->
    #res.status(400).json err
    #
module.exports = router;
