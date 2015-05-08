# TxtAdventure API

## /user/:userid/conversations
### GET

Returns a list of conversation headers for a user with the id `nuserid`. Each conversation contains the last message sent/received. If there is no last message, this field will not be populated.

Returns

    [{Contact:{id, number}, LastMessage}...]

Status Codes

    200 - OK
---

## /user/:userid/conversations/:conid
### GET

Returns a list of messages that occured between the user of id `userid` and user with id `conid`.

Returns

    [{FromUser:{id, number}, ToUser: {id, number}, message}...]

Status Codes

    200 - OK

### POST

Adds a new message to a conversation with id `conid` for user with id `userid`.

Body

    {message}

Status Codes

    200 - OK