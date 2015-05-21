express = require 'express'
router = express.Router mergeParams:true
validate = require "express-validation"
Promise = require 'bluebird'

sqlService = localRequire 'services/sqlService.js'
schemas = localRequire 'schemas.js'

router.param 'conid', (req, res, next, conid) ->
  sqlService.contacts.contactBelongsToUser req.params.userid, conid
  .then (belongs) ->
    if not belongs then res.sendStatus 404 else next()

router.get '/', (req, res) ->
  sqlService.contacts.getContactsForUser req.params.userid
  .then (contacts) ->
    res.json contacts

router.post '/', validate(body:schemas.ContactAddSchema), (req, res) ->
  sqlService.contacts.contactNumberBelongsToUser req.params.userid,req.body.number
  .then (belongs) ->
    if belongs then return res.sendStatus 409
    sqlService.contacts.addContactNumberToUser req.params.userid, req.body.number
    .then (contact) ->
      res.json contact
  
router.get '/:conid', (req, res) ->
  sqlService.contacts.findById req.params.conid
  .then (contact) ->
    res.send contact

router.delete '/:conid', (req, res) ->
  sqlService.contacts.deleteContact req.params.conid
  .then ->
    res.sendStatus 200

module.exports = router