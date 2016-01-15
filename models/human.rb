require_relative '../lib/model_base'

class Human < SQLObject
  self.finalize!
end
