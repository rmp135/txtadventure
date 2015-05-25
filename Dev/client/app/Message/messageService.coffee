angular.module 'Message'
.factory 'messageService', (userService, Message)->
    @getMessageHeaders = ->
        Message.query({userid:userService.currentUser.id})
    @getMessagesInMessage = (id) ->
        Message.query({userid:userService.currentUser.id, contactId:id})
    @sendMessageToContact = (contactId, message) ->
        Message.save({userid:userService.currentUser.id, contactId:contactId},{message:message})
    return @