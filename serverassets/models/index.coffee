fs = require 'fs'
path = require 'path'
Sequelize = require 'sequelize'
lodash = require 'lodash'
sequelize = new Sequelize 'db.sqlite3', null, null, {dialect:'sqlite', storage:'db.sqlite3'}
db = {}
fs.readdirSync __dirname
.filter (file) ->
    (file.indexOf('.') != 0 && file != 'index.js')
.forEach (file) ->
    model = sequelize.import(path.join(__dirname, file))
    db[model.name] = model

Object.keys(db).forEach (modelName) ->
    `if ('associate' in db[modelName]) {
        db[modelName].associate(db)
     }`
    return

module.exports = lodash.extend {sequelize:sequelize, Sequelize:Sequelize}, db
module.exports.sequelize= sequelize