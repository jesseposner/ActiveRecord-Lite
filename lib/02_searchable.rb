require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_params = params.keys.join(" = ? AND ").concat(" = ?")

    where_results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_params}
    SQL

    parse_all(where_results)
  end
end

class SQLObject
  extend Searchable
end
