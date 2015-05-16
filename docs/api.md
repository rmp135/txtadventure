# TxtAdventure API

## /user
### POST

Creates a new user with a given number and pin. The number must be 11 digits long. The PIN must be more than 4 digits.

#### Request Body

    {number, pin}

#### Reponse Body

    {id, number}

#### Response Cookies

    {session}
    
#### Request Codes

`400 - Number missing.`

`400 - PIN missing.`

`400 - Incorrect number length`

`400 - PIN too short.`

---

## /user/:id
### GET

Retrieves the details of a user.

#### Reponse Body

    {id, number}

#### Request Codes

`404 - User not found.`

### PUT

Updates a user with new details. See adding user for more details.

#### Request Body

    {number, pin}

#### Request Codes

`404 - User not found.`

`400 - Number missing`

`400 - PIN missing.`

`400 - Incorrect number length.`

`400 - PIN too short`

---
## /user/:userid/contacts
### GET

Retrieves the contacts for a user with id `userid`.

#### Response Body

    [{id, number}...]
    
#### POST

Adds a new contact to user with id `userid`.

#### Request Body

    {number}

#### Response Body

    {id, number}

---

## /user/:userid/messages
### GET

Returns a list of conversation headers for a user with the id `nuserid`. Each conversation contains the last message sent/received. If there is no last message, this field will not be populated.

#### Response Body

    [{Contact:{id, number}, LastMessage}...]

#### Response Codes

`404 - User not found.`

---

## /user/:userid/messages/:conid
### GET

Returns a list of messages that occured between the user of id `userid` and contact with id `conid`.

#### Response Body

    [{to, from, time, message}...]

#### Response Codes

`404 - User does not exist.`

`404 - Contact does not exist.`

### POST

Adds a new message to a conversation with id `conid` for contact with id `userid`.

#### Request Body

    {message}

#### Response Codes

TODO