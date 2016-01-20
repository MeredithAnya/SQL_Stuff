require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize

    super('questions.db')

    self.results_as_hash = true
    self.type_translation = true

  end
end


class Users

  attr_accessor :id, :first_name, :last_name


  def self.all

    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map {|result| Users.new(result)}

  end

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
       users
      WHERE
        users.id = ?
    SQL

    results.map { |result| Users.new(result) }
  end

  def self.find_by_name(first_name, last_name)
    results = QuestionsDatabase.instance.execute(<<-SQL, first_name, last_name)
      SELECT
        *
      FROM
       users
      WHERE
        users.first_name = ? AND
        users.last_name = ?

    SQL

    results.map { |result| Users.new(result) }
  end

  def self.followed_questions(id)
    QuestionFollows.followed_questions_for_user_id(id)
  end



  def initialize(options)
    @id, @first_name, @last_name = options.values_at('id', 'first_name', 'last_name')
  end

end










class Questions
  attr_accessor :id, :title, :body, :author_id

  def initialize(options)
    @id, @title, @body, @author_id = options.values_at('id', 'title', 'body', 'author_id')
  end

  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
       questions
      WHERE
        questions.author_id = ?
    SQL

    results.map { |result| Questions.new(result) }
  end

  def self.replies(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
       replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Replies.new(result) }
  end

  def self.followers(question_id)
    QuestionFollows.followers_for_question_id(question_id)
  end

  def self.most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def self.likers(question_id)
    QuestionLike.likers_for_question_id(question_id)
  end

  def self.num_likes(question_id)
    QuestionLike.num_likes_for_question_id(question_id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end


end





class QuestionFollows

  def initialize(options)
    @user_id, @question_id = options.values_at('user_id', 'question_id')
  end


  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN Users on Users.id = question_follows.user_id

      WHERE
        question_follows.question_id = ?
    SQL

    results.map { |result| Users.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN questions on questions.id = question_follows.question_id

      WHERE
        question_follows.user_id = ?
    SQL

    results.map { |result| Questions.new(result) }
  end

  def self.most_followed_questions(n)

    results = QuestionsDatabase.instance.execute(<<-SQL)

      SELECT
        *
      FROM
        question_follows
      JOIN questions ON questions.id = question_follows.question_id
      GROUP BY
       question_id
      ORDER BY
       count(question_id) DESC
    SQL

    output = results.map { |result| Questions.new(result) }
    output.take(n)
  end
end









class Replies


  attr_accessor :question_id, :reply_id, :user_id, :body, :parent

  def self.all

    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map {|result| Replies.new(result)}

  end


  def initialize(options)
    @question_id, @reply_id, @user_id, @body, @parent  = options.values_at('question_id', 'reply_id', 'user_id', 'body', 'parent')
  end


  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
       replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Replies.new(result) }
  end

  def self.find_by_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
       replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Replies.new(result) }
  end

  def self.child_replies(parent)
    results = QuestionsDatabase.instance.execute(<<-SQL, parent)
      SELECT
        *
      FROM
       replies
      WHERE
        replies.parent = ?
    SQL

    results.map { |result| Replies.new(result) }
  end

  def self.parent_replies(child)
    results = QuestionsDatabase.instance.execute(<<-SQL, child)
      SELECT
        *
      FROM
       replies
      WHERE
        replies.reply_id = (
          SELECT
            parent
          FROM
            replies
          WHERE
            reply_id = ?
        )
    SQL

    results.map { |result| Replies.new(result) }
  end

end

class QuestionLike
  attr_accessor :liked, :user_id, :question_id

  def initialize(options)
    @liked, @user_id, @question_id = options.values_at('liked', 'user_id', 'question_id')
  end

  def self.likers_for_question_id(question_id)
  results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
     question_likes
    JOIN users on question_likes.user_id = users.id

    WHERE
      question_likes.question_id = ?
  SQL

  results.map { |result| Users.new(result) }

  end

  def self.num_likes_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        count(*)
      FROM
       question_likes
      JOIN users on question_likes.user_id = users.id

      WHERE
        question_likes.question_id = ?
      SQL
  end


  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)

      SELECT
        *
      FROM
       question_likes
      JOIN questions on question_likes.question_id = questions.id

      WHERE
        question_likes.user_id = ?
    SQL

    results.map { |result| Questions.new(result) }

  end
  def self.most_liked_questions(n)

    results = QuestionsDatabase.instance.execute(<<-SQL)

      SELECT
        *
      FROM
        questions
      JOIN question_likes ON questions.id = question_likes.question_id
      GROUP BY
       questions.id
      ORDER BY
       count(*) DESC
    SQL

    output = results.map { |result| Questions.new(result) }
    output.take(n)
  end





end
