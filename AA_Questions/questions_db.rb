require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
    include Singleton 

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class Question
    attr_accessor :title, :body, :author_id

    def self.find_by_id(id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL
        return nil unless questions.length > 0

        Question.new(questions.first)
    end

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    def create
        raise "#{self} already in database" if @id

        QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
            INSERT INTO
                questions(title, body, author_id)
            VALUES
                (?, ?, ?);
        SQL

        @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} not in database" unless @id

        QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
            UPDATE
                questions
            SET
                title = ?, body = ?, author_id = ?
            WHERE
                id = ?;
        SQL
    end
end

class User
    attr_accessor :fname, :lname, :is_instructor

    def self.find_by_name(fname, lname)
        names = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?;
        SQL
        return nil unless names.length > 0

        User.new(names.first)
    end

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM users")
        data.map {|datum| User.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
        @is_instructor = options['is_instructor']||= false
    end

    def create
        raise "#{self} already in database" if @id

        QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @is_instructor)
            INSERT INTO
                users(fname, lname, is_instructor)
            VALUES
                (?, ?, ?);
        SQL

        @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} doesn't exist in database" unless @id

        QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @is_instructor, @id)
            UPDATE
                users
            SET
                fname = ?, lname = ?, is_instructor = ?
            WHERE
                id = ?;
        SQL
    end
end

class Reply
    attr_accessor :parent_reply_id, :author_id, :question_id, :body

    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                author_id = ?;
        SQL
        return nil unless reply.length > 0
        reply_arr = []

        replies.each do |reply|
            reply_arr << Reply.new(reply)
        end

        reply_arr
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?;
        SQL
        return nil unless replies.length > 0
        reply_arr = []

        replies.each do |reply|
            reply_arr << Reply.new(reply)
        end
        
        reply_arr
    end

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
        data.map {|datum| Reply.new(datum)}
    end

    def initialize(options)
        @id = options['id']
        @parent_reply_id = options['parent_reply_id']
        @author_id = options['author_id']
        @question_id = options['question_id']
        @body = options['body']
    end

    def create
        raise "#{self} already in database" if @id

        QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id, @author_id, @question_id, @body)
            INSERT INTO
                replies(parent_reply_id, author_id, question_id, body)
            VALUES
                (?, ?, ?, ?);
        SQL

        @id = QuestionsDatabase.instance.last_insert_row_id
    end

    def update
        raise "#{self} doesn't exist in database" unless @id

        QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id, @author_id, @question_id, @body, @id)
            UPDATE
                replies
            SET
                parent_reply_id = ?, author_id = ?, question_id = ?, body = ?
            WHERE
                id = ?;
        SQL
    end
end