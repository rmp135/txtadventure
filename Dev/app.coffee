express = require "express"
path = require "path"
cookieParser = require "cookie-parser"
bodyParser = require "body-parser"
debug = require("debug") "txtAdventure:app"

global.__serverPath = path.join __dirname, "/server"
global.localRequire = (name) ->
  require "#{__serverPath}/#{name}"


apiroutes = require "./server/routes"

app = express()

app.set 'views', path.join(__dirname, "/server/views")
app.set "view engine", "jade"

app.use (req, res, next) ->
  res.on "finish", ->
    status = res.statusCode
    if /40\d/.test(status) is true
      status = '\u001b[31m'+status+'\u001b[0m'
    else if status is 200
      status = '\u001b[32m'+status+'\u001b[0m'
    else if status is 304
      status = '\u001b[33m'+status+'\u001b[0m'
    debug "#{status} #{req.method} http://txtAdventure-rmp135.c9.io #{req.originalUrl}"
  next()

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended:false)
app.use cookieParser()
app.use express.static(path.join(__dirname, "./client"))

app.get "/", (rq, res) ->
  res.render "index"

app.use "/api", apiroutes

app.use (req, res, next) ->
  err = new Error "Not Found"
  err.status = 404
  next err

app.use (err, req, res, next) ->
  res.status err.status||500
  res.render "error", 
    message: err.message
    error:{}

module.exports = app