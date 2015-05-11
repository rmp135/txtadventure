INSERT INTO User(number)values('001'),('07752637462'),('07723648273'),('07782736421'),('07799872876');
INSERT INTO Contacts(UserId, ContactId)VALUES(1,2),(1,3),(1,4),(2,3),(1,5);

INSERT INTO Message(message, FromUserId, ToUserId)VALUES ('from 001 to 002', 1,2),('from 3 to 1', 3,1), ('from 4 to 1', 4,1), ('from 002 to 001',2,1), ('from 002 to 003',2,3), ('from 003 to 004',3,4), ('from 003 to 004 again',3,4);


DROP VIEW IF EXISTS 'getConversationHeaders';
CREATE VIEW getConversationHeaders AS
SELECT * FROM (
  SELECT c.ContactId ContactId, u.number number, CASE WHEN m.message IS NULL THEN 'No Messages.' ELSE m.message END LastMessage, m.UserId FROM Contacts c LEFT OUTER JOIN (
    SELECT FromUserId UserId, ToUserId ContactId, Message, id FROM Message
    UNION
    SELECT ToUserId UserId, FromUserId ContactId, Message, id FROM Message
  ) m on m.ContactId = c.ContactId
  JOIN User u on u.id = c.ContactId ORDER BY m.id asc
);


DROP VIEW IF EXISTS 'getConversationDetails';
CREATE VIEW getConversationDetails AS
    SELECT m.id, m.Message, fu.id "From.id", fu.number "From.number", tu.id "To.id", tu.number "To.number" FROM Message m JOIN User fu on fu.id = m.FromUserId JOIN User tu on tu.id = m.ToUserId;