# TxtAdventure API

## /user
### POST

Creates a new user with a given number and pin. The number must be 11 digits long. The PIN must be more than 4 digits.

#### Body

    {number, pin}

#### Returns

    {id, number}
    
#### Errors

`400 - Number missing.`

`400 - PIN missing.`

`400 - Incorrect number length`

`400 - PIN too short.`

---

## /user/:id
### GET

Retrives a users details.

#### Returns

    {number}

#### Errors

`404 - User not found.`

### PUT

Updates a user with new details. See adding user for more details.

#### Body

    {number, pin}

#### Status Codes

`404 - User not found.`

`400 - Number missing`

`400 - PIN missing.`

`400 - Incorrect number length.`

`400 - PIN too short`

---

## /user/:userid/conversations
### GET

Returns a list of conversation headers for a user with the id `nuserid`. Each conversation contains the last message sent/received. If there is no last message, this field will not be populated.

#### Returns

    [{Contact:{id, number}, LastMessage}...]

#### Errors

TODO

---

## /user/:userid/conversations/:conid
### GET

Returns a list of messages that occured between the user of id `userid` and user with id `conid`.

#### Returns

    [{FromUser:{id, number}, ToUser: {id, number}, message}...]

#### Errors

TODO

### POST

Adds a new message to a conversation with id `conid` for user with id `userid`.

#### Body

    {message}

#### Errors

TODO