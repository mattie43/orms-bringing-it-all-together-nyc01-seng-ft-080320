require 'pry'
class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT)
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
        new_dog
    end

    def self.new_from_db(arr)
        Dog.new(id: arr[0], name: arr[1], breed: arr[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        temp = DB[:conn].execute(sql,id).first
        self.new_from_db(temp)
    end

    def self.find_or_create_by(hash)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        AND breed = ?
        SQL
        
        arr = DB[:conn].execute(sql, hash[:name], hash[:breed]).first
        if arr == nil
            self.create(hash)
        else
            self.new_from_db(arr)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL

        temp = DB[:conn].execute(sql,name).first
        self.new_from_db(temp)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end