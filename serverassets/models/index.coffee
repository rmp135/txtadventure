fs = require 'fs'
path = require 'path'
Sequelize = require 'sequelize'
lodash = require 'lodash'
Promise = require 'bluebird'
debug = require('debug') 'txtAdventure:db'
sqlite3 = require 'sqlite3'

sequelize = null

models = {}

query = (query) ->
    sequelize.query query

recreate = (options) ->
  if not sequelize? then throw "A database context must be created before the database can be recreated."
  debug "Recreating database."    
  return new Promise (resolve, reject) ->
    sequelize.sync force:(if options?.force then options.force else false)
    .then ->
      debug "Completed database recreation."
      resolve()
      return
    .catch (err) ->
      if (err)
        throw err;
    
loadFixtures = (fixtureFile) ->
  if not sequelize? then throw "A database context must be created before a fixture can be loaded."
  return new Promise (resolve, reject) =>
    debug "Loading fixtures from file #{fixtureFile}"
    db = new sqlite3.Database sequelize.config.database
    fs.readFile fixtureFile, 'utf8', (err, inserts) ->
      if err
        reject err
      else
        db.exec inserts, (err) ->
          if err
            reject err
          else
            debug "Fixtures inserted."
            resolve()

createContext = (options) ->
  if not options?.storage then throw "A storage name must be provided."
  storage = options.storage + '.sqlite3'
  sequelize = new Sequelize storage, null, null, {dialect:'sqlite', storage:storage, logging: if options?.logging then require("debug")("sequelize") else false}
  debug 'Synchronising models.'
  fs.readdirSync __dirname
  .filter (file) ->
      (file.indexOf('.') != 0 && file != 'index.js')
  .forEach (file) =>
    model = sequelize.import(path.join(__dirname, file))
    models[model.name] = model
  
  Object.keys(@models).forEach (modelName) =>
    if 'associate' of _this.models[modelName]
      @models[modelName].associate(@models)
  debug "Completed model synchronisation."
  debug "Using database #{options.storage}."

module.exports = {models, query, loadFixtures, createContext, recreate}

#exports.query = (query) ->
  #debug "Attempting to run query."
  #return new Promise (resolve, reject) ->
      #if sequelize?
          #sequelize.query query
          #.then (results) ->
              #resolve results
      #else
          #debug "Context has not been created."
          #reject "Context has not been created."
#
#exports.sync = (options) -> 
  #new Promise (resolve, reject) ->
      #if not sequelize?
          #reject "Context has not been created."
          #return
      #debug 'Synchronising models.'
      #fs.readdirSync __dirname
      #.filter (file) ->
          #(file.indexOf('.') != 0 && file != 'index.js')
      #.forEach (file) ->
          #model = sequelize.import(path.join(__dirname, file))
          #db[model.name] = model
      #
      #Object.keys(db).forEach (modelName) ->
          #`if ('associate' in db[modelName]) {
              #db[modelName].associate(db)
           #}`
          #return
      #db: lodash.extend {sequelize:sequelize, Sequelize:Sequelize}
      #sequelize.sync force:(if options?.force then options.force else false)
      #.catch (err) ->
        #if (err)
          #throw err;
      #.then ->
          #do resolve
          #return
  #
#exports.loadFixtures = (fixtureFile) ->
  #return new Promise (resolve, reject) ->
      #if not sequelize?
          #reject "Context has not been created."
          #return
      #debug "Loading fixtures from file #{fixtureFile}"
      #db = new sqlite3.Database sequelize.config.database
      #
      #fs.readFile fixtureFile, 'utf8', (err, inserts) ->
          #if err
              #reject err
          #else
              #db.exec inserts, (err) ->
                  #if err
                      #reject err
                  #else
                      #debug "Fixtures inserted."
                      #resolve()