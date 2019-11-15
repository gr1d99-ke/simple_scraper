class Link < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
