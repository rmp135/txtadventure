angular.module 'app.services', ['app.resources']
.factory 'messageService', (phoneService, Conversation)->
    @getConversationHeaders = ->
        Conversation.query({userid:phoneService.currentUser.id})
    @getMessagesInConversation = (id) ->
        Conversation.query({userid:phoneService.currentUser.id, contactId:id})
    @sendMessageToContact = (contactId, message) ->
        Conversation.save({userid:phoneService.currentUser.id, contactId:contactId},{message:message})
    return @
.factory 'contactService', (phoneService, Contact) ->
    @getContacts = ->
        Contact.query id:1
    @addContact = (number) ->
        Contact.save id:phoneService.currentUser.id, {number}
    return @
.factory 'phoneService', ->
    @currentUser = {id:1, number:"001"}
    return @