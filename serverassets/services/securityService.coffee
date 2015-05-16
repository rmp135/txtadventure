bcrypt = require "bcrypt"
Promise = require 'bluebird'

generateHash = (password) ->
  new Promise (resolve, reject) ->
    bcrypt.hash password, 10, (err, hash) ->
      return reject err if err
      resolve hash
  
isAuthed = (password, hash) ->
  new Promise (resolve, reject) ->
    bcrypt.compare password, hash, (err, res) ->
      return reject err if err
      resolve res

module.exports = {generateHash, isAuthed}