class ScrapedUri < ApplicationRecord
  belongs_to :uri
  belongs_to :user
end
