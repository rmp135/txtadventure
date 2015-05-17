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
  sqlService.accounts.findById userid
  .then (user) ->
    if not user then res.sendStatus 404 else next()

router.post '/', validate(body:schemas.UserCreateSchema), (req, res) ->
  sqlService.accounts.createNewAccount req.body.number, req.body.pin
  .then (user) ->
    res.json user

router.get '/:userid', (req, res) ->
  sqlService.accounts.findById req.params.userid
  .then (user) ->
    res.json user

router.use '/:userid/messages', userMessagesRoutes
router.use '/:userid/contacts', userContactRoutes

module.exports = router