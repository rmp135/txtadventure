angular.module 'Contact'
.factory 'contactService', (userService, Contact) ->
    contactService = {}

    contactService.getContacts = ->
        Contact.query id:userService.currentUser.id
    contactService.addContact = (number) ->
        Contact.save id:userService.currentUser.id, {number}
    contactService.removeContactWithId = (conid) ->
        Contact.delete id:userService.currentUser.id, contactId:conid

    return contactService