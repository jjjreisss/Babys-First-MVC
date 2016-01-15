require_relative '../lib/model_base'
require_relative 'human'

class Cat < SQLObject
  belongs_to(
    "owner",
    {
      class_name: Human,
      foreign_key: :owner_id,
    }
  )
  self.finalize!
end
