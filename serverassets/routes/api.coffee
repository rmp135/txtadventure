express = require 'express'
router = express.Router()
sqlService = require '../services/sqlService.js'

router.route '/login'
.post (req, res) ->
    sqlService.accounts.findById req.body.id
    .then (user) ->
        if not user
            res.sendStatus 403

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

module.exports = router;
