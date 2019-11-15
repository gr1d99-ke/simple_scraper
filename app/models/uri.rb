class Uri < ApplicationRecord
  belongs_to :user
  has_many :scraped_uris
end
