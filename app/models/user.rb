class User < ApplicationRecord
  has_many :uris, dependent: :destroy
  has_many :scraped_uris, dependent: :destroy
end
