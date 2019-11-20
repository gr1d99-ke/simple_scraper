require "reform/form/validation/unique_validator.rb"

class UriForm < Reform::Form
  properties :name, :host, :user_id

  validates :name, presence: true, unique: true
  validates :host, presence: true, host: true
  validates :user_id, presence: true
end
