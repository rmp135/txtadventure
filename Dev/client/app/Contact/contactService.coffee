angular.module 'Contact'
.factory 'contactService', (userService, Contact) ->
    @getContacts = ->
        Contact.query id:1
    @addContact = (number) ->
        Contact.save id:phoneService.currentUser.id, {number}
    @removeContactWithId = (conid) ->
        Contact.delete id:phoneService.currentUser.id, contactId:conid
    return @