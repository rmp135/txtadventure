DELETE FROM User;
DElETE FROM Conversation;
DELETE FROM Message;

INSERT INTO User(number)values('001'),('002'),('003'),('004');
INSERT INTO Conversation(id)VALUES(null),(null),(null);
INSERT INTO Message(message, ConversationId, UserId)VALUES
    ('this is a message', 1,1),
    ('this is a reply',1,2),
    ('this is for another conversation',2,3),
    ('message from 1',3,1),
    ('message back from 4',3,4);

DROP VIEW IF EXISTS 'getConversationHeaders';
CREATE VIEW getConversationHeaders AS 
SELECT * FROM
    (SELECT c.id 'Conversation.id', m.message 'Conversation.snippet', cu.UserId 'User.id' FROM Conversation c JOIN (SELECT c.id ConversationId, m.UserId FROM Conversation c JOIN Message m on m.ConversationId = c.id) cu on c.id = cu.ConversationId JOIN Message m on m.ConversationId = c.id ORDER BY m.id);