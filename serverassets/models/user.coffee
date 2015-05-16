module.exports = (sequelize, DataTypes) ->
    User = sequelize.define 'User',
     #id: {type: DataTypes.INTEGER, autoIncrement:true},
     number: {type: DataTypes.STRING},
     passHash: DataTypes.STRING
    ,
     freezeTableName:true, timestamps:false
     classMethods: 
      associate: (models) ->
       User.hasMany models.Contact, { as:'Contacts', foreignKey:'UserId' }
       #User.hasMany models.Contact, { as:'Users' }
       #User.belongsToMany models.User, { as:'Contacts', through:models.Contacts, foreignKey:{name:'UserId', allowNull:true}, constraints:false, unique:false}
       #User.belongsToMany models.User, { as:'Contacts', through:models.Contacts, foreignKey:{name:'ContactId', allowNull:true, primaryKey:false}, constraints:false, unique:false}
    return User