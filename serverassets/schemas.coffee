Joi = require('joi')

@ContactSchema = Joi.object().keys(
  id: Joi.number().required()
  number: Joi.string().required()
)

@ConversationListSchema = Joi.array().items(Joi.object().keys(
  LastMessage: Joi.string().required()
  Contact: @ContactSchema
  )
)

@ConversationSchema = Joi.array().items(Joi.object().keys(
  From: @ContactSchema
  To: @ContactSchema
  message: Joi.string().required())
)

@MessageSchema = Joi.object().keys(
  message: Joi.string().required()
  To: @ContactSchema
)

@UserCreateSchema = Joi.object().keys(
  number: Joi.string().length(11).required()
  pin: Joi.string().min(3).required()
)

module.export = this