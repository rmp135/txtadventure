express = require 'express'
router = express.Router()
sqlService = require '../services/sqlService.js'
schemas = require '../schemas.js'
validate = require "express-validation"
debug = require("debug") "txtAdventure:api"
Promise = require 'bluebird'

userRoutes = require './user/userRoutes.js'

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

router.use '/user', userRoutes

module.exports = router;
