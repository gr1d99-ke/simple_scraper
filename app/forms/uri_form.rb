# frozen_string_literal: true

require 'reform/form/validation/unique_validator.rb'

class UriForm < Reform::Form
  properties :name, :host, :user_id

  validates :name, presence: true, unique: true
  validates :host, presence: true, host: true
end
