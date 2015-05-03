# TxtAdventure API

## /user/:userid/conversations
### GET

Returns a list of conversation headers for a user with the id `nuserid`. Each conversation contains the last message sent/received.


    `[{id, message}...]`

> 200 - OK
---

## /user/:userid/conversations/:conid
### GET

Returns a list of messages that belong to the conversation with id `conid` for a user with the id `userid`.

    `[{message, User:{number}}...]`

### POST

Adds a new message to a conversation with id `condi` for usr with id `userid`.

    '{message}`

> 200 OK If successful.