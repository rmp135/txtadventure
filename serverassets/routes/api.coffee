express = require 'express'
router = express.Router()
sqlService = require '../services/sqlService.js'
schemas = require '../schemas.js'
validate = require "express-validation"
debug = require("debug") "txtAdventure:api"

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

router.route '/user/:userid/conversations/:conid'
.get (req,res) ->
    sqlService.messages.getConversationBetweenUsers req.params.userid, req.params.conid
    .then (messages) ->
        res.json messages
        return
    return
.post (req, res) ->
    sqlService.messages.addMessageBetweenUsers req.params.userid, req.params.conid, req.body.message
    .then ->
        res.sendStatus 200

router.route '/user/:id/conversations'
.get (req,res) ->
    sqlService.messages.getConversationsForUser req.params.id
    .then (conversations) ->
        res.json conversations
        return
    return

router.use (err, req, res, next) ->
    res.status(400).json err
    
module.exports = router;
