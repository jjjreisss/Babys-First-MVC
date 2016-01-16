require 'active_support/inflector'
require 'require_all'
require_rel 'model_modules/*'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    @columns || (
      column_data = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      column_data.first.map{ |column| column.to_sym})
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |val|
        attributes[column] = val
      end
      define_method(column) do
        attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    parse_all(
      DBConnection.execute(<<-SQL)
        SELECT #{table_name}.*
        FROM #{table_name}
      SQL
      )
  end

  def self.parse_all(results)
    results.map{ |row| new(row)}
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL
    return nil if results.empty?
    new(results.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      symbolized = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(symbolized)
      send("#{attr_name}=", value)
    end
    self.class.finalize!
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map{ |column| send("#{column}")}
  end

  def insert
    question_marks = (["?"] * self.class.columns.length).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name}
      VALUES (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update
    set_line = self.class.columns.map { |column| "#{column} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
