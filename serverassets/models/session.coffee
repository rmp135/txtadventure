module.exports = (sequelize, DataTypes) ->
    Session = sequelize.define 'Session',
     token:DataTypes.STRING
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
        Session.belongsTo models.User, {as:'User', foreignKey: 'UserId' }
    return Session