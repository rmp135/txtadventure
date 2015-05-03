module.exports = (sequelize, DataTypes) ->
    User = sequelize.define 'User',
     number:DataTypes.STRING
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       User.belongsToMany models.Conversation, through: 'ConversationUser'
    return User