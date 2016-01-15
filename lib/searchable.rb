require_relative 'db_connection'
require_relative 'model_base'

module Searchable
  def where(params)
    # where_line = params.map{ |h, k| "#{h} = '#{k}'"}.join(" AND ")
    where_line = params.keys.map { |attribute| "#{attribute} = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT *
      FROM #{table_name}
      WHERE #{where_line}
    SQL

    results.map do |row|
      new(row)
    end
  end
end

class SQLObject
  extend Searchable
end
