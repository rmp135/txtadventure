Joi = require('joi')

ContactSchema = Joi.object().keys(
  id: Joi.number().required()
  number: Joi.string().required()
)

ConversationListSchema = Joi.array().items(Joi.object().keys(
  LastMessage: Joi.string().required()
  Contact: ContactSchema
  )
)

NewMessageSchema= Joi.object().keys(
  message: Joi.string().required()
)

ContactAddSchema = Joi.object().keys(
  number: Joi.string().regex(/^[0-9]+$/).required()
).required()

MessageSchema = Joi.object().keys(
  message: Joi.string().required()
  time: Joi.date()
  from: Joi.string().required()
  to: Joi.string().required()
)
ConversationSchema = Joi.array().items(MessageSchema)

UserCreateSchema = Joi.object().keys(
  number: Joi.string().length(11).required()
  pin: Joi.string().min(3).required()
)

ContactListSchema = Joi.array().items(ContactSchema)

module.exports = {ContactSchema, ConversationSchema, ConversationListSchema, MessageSchema, UserCreateSchema, ContactListSchema, NewMessageSchema, ContactAddSchema}