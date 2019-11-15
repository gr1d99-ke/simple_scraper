require "reform/form/validation/unique_validator.rb"

class UserForm < Reform::Form
  property :email

  validates :email, presence: true, unique: true
end
