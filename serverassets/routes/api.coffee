express = require 'express'
router = express.Router()
messageService = require '../services/messageService.js'

router.route '/user/:userid/conversations/:conid'
.get (req,res) ->
    messageService.getAllMessagesForConversation req.params.conid
    .then (messages) ->
        res.json messages
        return
    return

router.route '/user/:id/conversations'
.get (req,res) ->
    messageService.getAllConversationsForUser req.params.id
    .then (conversations) ->
        res.json conversations
        return
    return

module.exports = router;
