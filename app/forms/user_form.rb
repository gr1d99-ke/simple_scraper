# frozen_string_literal: true

require 'reform/form/validation/unique_validator.rb'

class UserForm < Reform::Form
  property :email
  property :password

  validates :email, presence: true, unique: true
end
