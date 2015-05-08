express = require 'express'
router = express.Router()

router.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'
.get '/test', (req,res,next) ->
    messageService.getAllConversationsForUser 2
    .then (user) ->
        res.json user
        return
    return

module.exports = router;
