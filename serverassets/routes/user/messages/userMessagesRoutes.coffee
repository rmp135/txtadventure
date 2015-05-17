express = require 'express'
router = express.Router mergeParams:true
validate = require "express-validation"
Promise = require 'bluebird'

sqlService = require 'sqlService'
schemas = require 'schemas'

router.param 'conid', (req, res, next, conid) ->
  sqlService.contacts.contactBelongsToUser req.params.userid, conid
  .then (belongs) ->
    if not belongs then res.sendStatus 404 else next()

router.route '/'
.get (req,res) ->
  console.log 'this is the user messages'
  sqlService.messages.getConversationsForUser req.params.id
  .then (conversations) ->
      res.json conversations

router.get '/:conid', (req,res) ->
  sqlService.messages.getConversationBetweenUserAndContact req.params.userid, req.params.conid
  .then (messages) ->
      res.json messages

router.post '/:conid', validate(body:schemas.NewMessageSchema), (req, res) ->
  sqlService.messages.sendMessageToContact req.params.userid, req.params.conid, req.body.message
  .then ->
      res.sendStatus 200


module.exports = router