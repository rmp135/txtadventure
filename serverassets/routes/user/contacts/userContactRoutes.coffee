express = require 'express'
router = express.Router mergeParams:true
sqlService = require '../../../services/sqlService.js'
schemas = require '../../../schemas.js'
validate = require "express-validation"
Promise = require 'bluebird'

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

module.exports = router