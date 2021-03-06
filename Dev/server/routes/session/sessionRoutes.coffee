express = require 'express'
router = express.Router()
validate = require "express-validation"
debug = require("debug") "txtAdventure:api"
Promise = require 'bluebird'

schemas = localRequire 'schemas.js'
sqlService = localRequire 'services/sqlService.js'


router.get '/session/:token', (req, res) ->
  sqlService.accounts.findBySessionToken req.params.token
  .then (user) ->
    if not user then return res.sendStatus 404
    res.json user

router.post '/login', validate(body:schemas.UserCreateSchema), (req, res) ->
  sqlService.accounts.isAuthed req.body.number, req.body.pin
  .then (authed) ->
    if not authed then return res.sendStatus 403
    sqlService.accounts.findByNumber req.body.number
    .then (user) ->
      sqlService.sessions.createSessionForUserId user.id
      .then (session) ->
        res.cookie 'session', session.token
        res.json user

router.post '/logout', (req, res) ->
  res.clearCookie 'session', path:'/'
  if not req.cookies.session
    return res.sendStatus 200
  sqlService.accounts.findBySessionToken req.cookies.session
  .then (user) ->
    if not user
      return res.sendStatus 200
    sqlService.sessions.deleteForUserId user.id
    .then ->
      res.sendStatus 200

module.exports = router;
