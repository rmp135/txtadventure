sqlService = require 'sqlService'
Promise = require 'bluebird'
request = require 'supertest'

Promise.promisifyAll request.Test::
request.Test::setSession = (session) -> @set 'Cookie', "session=#{session.token}"; return @


genNumber = ->
  tail = Math.round(Math.random()*Math.pow(10,8))
  '077' + if tail > Math.pow(10,7) then tail else '0'+tail

genPassword = ->
  String Math.round(Math.random()*Math.pow(10,4))

login = (number, password) ->
  number = genNumber() if not number?
  password = genPassword() if not password?
  return new Promise (resolve, reject) ->
    sqlService.accounts.createNewAccount number, password
    .then (user) ->
      sqlService.sessions.createSessionForUserId user.id
      .then (session) ->
        resolve {user, session}

createAccount = (number, password) ->
  number = genNumber() if not number?
  password = genPassword() if not password?
  return sqlService.accounts.createNewAccount number, password

module.exports = {genNumber, genPassword, login, createAccount}