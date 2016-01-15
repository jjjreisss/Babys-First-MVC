require_relative '../active-record-create/lib/sql_object'

class Cat < SQLObject
  self.finalize!
end
