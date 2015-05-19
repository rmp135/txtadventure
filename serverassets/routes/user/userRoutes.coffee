express = require 'express'
router = express.Router()
validate = require "express-validation"
debug = require("debug") "txtAdventure:routes"
Promise = require 'bluebird'

sqlService = require 'sqlService'
schemas = require 'schemas'
userMessagesRoutes = require './messages/userMessagesRoutes.js'
userContactRoutes = require './contacts/userContactsRoutes.js'

router.param 'userid', (req, res, next, userid) ->
  if not req.cookies.session then return res.sendStatus 403
  sqlService.accounts.findBySessionToken req.cookies.session
  .then (user) ->
    if user.id isnt +req.params.userid then res.sendStatus 403 else next()

router.post '/', validate(body:schemas.UserCreateSchema), (req, res) ->
  sqlService.accounts.findByNumber req.body.number
  .then (user) ->
    if user? then return res.sendStatus 409
    sqlService.accounts.createNewAccount req.body.number, req.body.pin
    .then (user) ->
      res.json user

router.get '/:userid', (req, res) ->
  Promise.join (sqlService.accounts.findById req.params.userid), (sqlService.accounts.findBySessionToken req.cookies.session)
  .then (results) ->
    [user, sessionUser] = results
    if sessionUser.id isnt user.id then return res.sendStatus 403
    res.json user

router.use '/:userid/messages', userMessagesRoutes
router.use '/:userid/contacts', userContactRoutes

module.exports = router