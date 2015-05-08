module.exports = (sequelize, DataTypes) ->
    Message = sequelize.define 'Message',
     message:DataTypes.STRING
     time: DataTypes.DATE
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       Message.belongsTo models.User, as:'FromUser'
       Message.belongsTo models.User, as:'ToUser'
       return
    return Message