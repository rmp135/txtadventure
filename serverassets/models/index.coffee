fs = require 'fs'
path = require 'path'
Sequelize = require 'sequelize'
lodash = require 'lodash'
#sequelize = undefined;
Promise = require 'bluebird'
debug = require('debug') 'txtAdventure:db'
sqlite3 = require 'sqlite3'

class Context
  constructor: (@sequelize) ->
    @models = {}
  query: (query) ->
    @sequelize.query query
  sync: (options) ->
    return new Promise (resolve, reject) =>
      debug 'Synchronising models.'
      fs.readdirSync __dirname
      .filter (file) ->
          (file.indexOf('.') != 0 && file != 'index.js')
      .forEach (file) =>
        model = @sequelize.import(path.join(__dirname, file))
        this.models[model.name] = model
      
      Object.keys(@models).forEach (modelName) =>
        if 'associate' of _this.models[modelName]
          @models[modelName].associate(@models)
        return
      @sequelize.sync force:(if options?.force then options.force else false)
      .catch (err) ->
        if (err)
          throw err;
      .then ->
        debug "Completed model synchronisation."
        do resolve
        return
              
  loadFixtures: (fixtureFile) ->
    return new Promise (resolve, reject) =>
      debug "Loading fixtures from file #{fixtureFile}"
      db = new sqlite3.Database @sequelize.config.database
      
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

#
#db = {}
#
#exports.models = db
#
#exports.destroyContext = ->
  #sequelize = undefined
  #return 
  #
exports.createContext = (options) ->
  storage = if options?.storage then options.storage + '.sqlite3' else 'db.sqlite3'
  debug "Using database #{storage}."
  sequelize = new Sequelize storage, null, null, {dialect:'sqlite', storage:storage, logging: if options?.logging then require("debug")("sequelize") else false}
  new Context sequelize

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