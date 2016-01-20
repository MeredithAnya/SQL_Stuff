DROP TABLE IF EXISTS users;
CREATE TABLE users
(id INTEGER PRIMARY KEY,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions
(id INTEGER PRIMARY KEY,
title VARCHAR NOT NULL,
body VARCHAR NOT NULL,
author_id INTEGER NOT NULL,
FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows
(user_id INTEGER NOT NULL,
question_id INTEGER NOT NULL);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies
(reply_id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  body VARCHAR NOT NULL,
  parent INTEGER NOT NULL
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes
( user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL
);

INSERT INTO users(first_name, last_name)
  VALUES
    ('Kanye', 'West'),
    ('Will', 'Smith'),
    ('Fresh', 'Princess'),
    ('J', 'Law');


INSERT INTO questions(title, body, author_id)
  values
  ('Hey lol how do i code', 'oh man what is even happening', 2),
  ('Is it cool if we call you winnie da pooh', ';)', 4),
  ('Banana?', 'What is this yellow thing, help',2);


INSERT INTO replies(question_id, user_id, body, parent)
  values
  (1, 4, 'Bro its easy', 0),
  (1, 1, 'Define easy', 1),
  (1,1, 'lol so easy', 1);

INSERT INTO question_follows(user_id, question_id)
  values
  (1,1),
  (3,1);


INSERT INTO question_likes(user_id, question_id)
  VALUES
    (1, 1),
    (1, 3);
