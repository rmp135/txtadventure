angular.module 'app.services', ['app.resources']
.factory 'messageService', (phoneService, Conversation)->
    @conversations = [
            id:2, from: "07728372382", message:"This is a conversation."
        ,
            id:3, from: "07786726321", message:"This is another conversation."
            ]
    @conversationDetail =
        id:2
        from:'07782637263'
        to: '07723482736'
        messages : [
            from:'07782637263'
            message: 'Careful you idiot! I said across her nose, not up it!'
        ,
            from:'07723482736'
            message: 'Sorry sir! I\'m doing my best!'
        ,
            from:'07782637263'
            message: 'Who made that man a gunner?.'
        ,
            from:'07723482736'
            message: 'I did sir. He\'s my cousin.'
        ,
            from:'07782637263'
            message: 'Who is he?'
        ,
            from:'07723482736'
            message: 'He\'s an asshole sir.'
        ,
            from:'07782637263'
            message: 'I know that. What\'s his name?'
        ,
            from:'07723482736'
            message: 'That is his name sir. Asshole, Major Asshole!'
        ,
            from:'07782637263'
            message: 'And his cousin?'
        ,
            from:'07723482736'
            message: 'He\'s an asshole too sir. Gunner\'s mate First Class Philip Asshole!'
        ,
            from:'07782637263'
            message: 'How many assholes do we have on this ship, anyway?'
        ,
            from:'07782637263'
            message: 'I knew it. I\'m surrounded by assholes!'
        ,
            from:'07782637263'
            message: 'Keep firing, assholes!'
            ]
    @getConversationHeaders = ->
        Conversation.query({userid:phoneService.id})
    @getMessagesInConversation = (id) ->
        Conversation.query({userid:phoneService.id, id:id})
    @sendMessageToUser = (userid, message) ->
        Conversation.save({userid:phoneService.id, id:userid},{message:message})
    return @
.factory 'phoneService', ->
    @number = "001"
    @id = 1
    return @