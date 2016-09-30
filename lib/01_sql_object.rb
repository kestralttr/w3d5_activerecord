require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if !@columns.nil?
    arr = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL

    @columns = arr.first.map {|el| el.to_sym}
    # ...
  end

  def self.finalize!
    columns = self.columns
    columns.each do |col|
      define_method(col) do
        self.attributes[col]
        #instance_variable_get("@#{col}")
      end
      define_method("#{col}=") do |value|
        self.attributes[col] = value
        #instance_variable_set("@#{col}", value)
      end
    end
          #make getter and setter methods for each column
  end

  def self.table_name=(table_name)
    @table_name = table_name
    # ...
  end

  def self.table_name
    @table_name ||= self.name.underscore.pluralize
    # ...
  end

  def self.all
    hashes = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.*
      FROM #{table_name}
    SQL
    parse_all(hashes)
    # ...
  end

  def self.parse_all(results)
    results.map do |hsh|
      self.new(hsh)
    end
    # ...
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT #{table_name}.*
      FROM #{table_name}
      WHERE #{table_name}.id = ?

    SQL

    parse_all(results).first
    # ...
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute \'#{k}\'" if !self.class.columns.include?(k.to_sym)
      self.send("#{k}=", v)
    end
    # ...
  end

  def attributes
    @attributes ||= {}
    # ...
  end

  def attribute_values
    # ...
  end

  def insert
    cols = self.class.columns.join(", ")
    DBConnection.execute(<<-SQL)
      INSERT INTO #{self.class.table_name} #{cols}
      VALUES

    SQL

    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
