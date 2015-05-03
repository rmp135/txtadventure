module.exports = (sequelize, DataTypes) ->
    Message = sequelize.define 'Message',
     message:DataTypes.STRING
     time: DataTypes.DATE
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       Message.belongsTo models.Conversation
       Message.belongsTo models.User
       return
    return Message