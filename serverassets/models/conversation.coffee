module.exports = (sequelize, DataTypes) ->
    Conversation = sequelize.define 'Conversation',
     {}
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       Conversation.belongsToMany models.User, through:'ConversationUser'
    return Conversation