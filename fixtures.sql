INSERT INTO User(number)values('001'),('07752637462'),('07723648273'),('07782736421'),('07799872876');

INSERT INTO Contact(UserId, number)VALUES
(1,'07752637462'), 
(1,"08876273628"),
(1,'07723648273'),
(2, '07723648273');

INSERT INTO Message(message, ToContactId)VALUES
('from 1 to 2', 1),
('from 1 to 08876273628', 2),
('from 2 to 07723648273', 4);

DROP VIEW IF EXISTS 'getConversationDetails';
CREATE VIEW getConversationDetails AS
  SELECT c.UserId FromUserId, fromUser.number 'FromUser.number', c.number 'ToContact.number', c.id ToContactId, u.id ToUserId, m.message, m.time FROM Message m
  JOIN Contact c on c.id = m.ToContactId
  JOIN User fromUser ON fromUser.id = c.UserId
  LEFT OUTER JOIN User u on u.number = c.number;

DROP VIEW IF EXISTS 'getConversationHeaders';
CREATE VIEW getConversationHeaders AS
  SELECT id ContactId, number, IFNULL(message, 'No messages.') LastMessage, UserId FROM (
  	SELECT * FROM Contact c
  	LEFT OUTER JOIN USER u on u.number = c.number
  	LEFT OUTER JOIN (
  			SELECT * FROM (
  				SELECT m.id MessageId, c.UserId FromUserId, u.id ToUserId, m.Message FROM Message m
  				JOIN Contact c on c.id = m.ToContactId
  				LEFT OUTER JOIN User u on u.number = c.number
  				UNION
  				SELECT m.id MessageId, u.id FromUserId,  c.UserId ToUserId, m.Message FROM Message m
  				JOIN Contact c on c.id = m.ToContactId
  				LEFT OUTER JOIN User u on u.number = c.number
  			) 
  	)  m on m.ToUserId = u.id
  	order by MessageId asc
  );