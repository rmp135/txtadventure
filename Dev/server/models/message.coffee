module.exports = (sequelize, DataTypes) ->
    Message = sequelize.define 'Message',
     message:DataTypes.STRING
     time: DataTypes.DATE
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       #Message.belongsTo models.User, as:'FromUser', foreignKey:'FromUserId'
       Message.belongsTo models.Contact, as:'ToContact', foreignKey:'ToContactId'
       return
    return Message