class User < ApplicationRecord
  has_many :uris
  has_many :scraped_uris
end
