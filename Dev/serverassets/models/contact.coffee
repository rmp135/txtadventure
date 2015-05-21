module.exports = (sequelize, DataTypes) ->
    Contact = sequelize.define 'Contact',
     number:DataTypes.STRING
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
        Contact.belongsTo models.User, {as:'User', foreignKey: 'UserId' }
        #Contact.belongsTo models.User, {as:'CContact', foreignKey: 'ContactId'}
    return Contact