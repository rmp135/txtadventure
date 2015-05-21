module.exports = (sequelize, DataTypes) ->
    User = sequelize.define 'User',
     number: {type: DataTypes.STRING},
     passHash: DataTypes.STRING
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       User.hasMany models.Contact, { as:'Contacts', foreignKey:'UserId' }
       User.hasMany models.Session, { as:'Sessions', foreignKey:'UserId' }
    return User