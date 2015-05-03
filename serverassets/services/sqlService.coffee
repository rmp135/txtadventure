db = require "../models"

module.exports = 
    selectFromView: (viewname, where) ->
        query = "SELECT * FROM "
        if not viewname?
            throw 'A view name must be specified.'

        query += viewname
        if where?
            query += ' ' + where
        
        query += ";"
        
        db.sequelize.query(query)