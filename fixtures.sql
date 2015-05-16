INSERT INTO User(number)values('001'),('07752637462'),('07723648273'),('07782736421'),('07799872876');

INSERT INTO Contact(UserId, number)VALUES
(1,'07752637462'), 
(1,"08876273628"),
(1,'07723648273'),
(2, '07723648273');

INSERT INTO Message(message, FromUserId, ToContactId)VALUES
('from 1 to 2', 1,1),
('from 1 to 08876273628', 1,2),
('from 2 to 07723648273', 2,4);

-- DROP VIEW IF EXISTS 'getConversationDetails';
-- CREATE VIEW getConversationDetails AS


--     SELECT m.id, m.Message, fu.id "From.id", fu.number "From.number", tu.id "To.id", tu.number "To.number" FROM Message m JOIN User fu on fu.id = m.FromUserId JOIN User tu on tu.id = m.ToUserId;