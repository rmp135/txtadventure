express = require 'express'
router = express.Router()
validate = require "express-validation"
debug = require("debug") "txtAdventure:api"
Promise = require 'bluebird'

schemas = require 'schemas'
sqlService = require 'sqlService'

userRoutes = require './user/userRoutes.js'
sessionRoutes = require './session/sessionRoutes.js'

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


router.use '/', sessionRoutes
router.use '/user', userRoutes

module.exports = router;
