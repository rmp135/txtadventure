angular.module 'app.services', ['app.resources']
.factory 'messageService', (phoneService, Conversation)->
    @getConversationHeaders = ->
        Conversation.query({userid:phoneService.currentUser.id})
    @getMessagesInConversation = (id) ->
        Conversation.query({userid:phoneService.currentUser.id, id:id})
    @sendMessageToUser = (userid, message) ->
        Conversation.save({userid:phoneService.currentUser.id, id:userid},{message:message})
    return @
.factory 'contactService', (Contact) ->
    @getContacts = ->
        Contact.query id:1
    return @
.factory 'phoneService', ->
    @currentUser = {id:1, number:"001"}
    return @